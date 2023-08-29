"""
An assembler for the LEAP architecture.

5 General purpose registers:
    r0-r4

1 Arithmetic Intermediate register:
    r5

    This is used to hold intermediate values when
    calculating XOR, AND, and OR. This means
    the value will not persist after any one of
    these functions are called. Only use it if you
    are not depending on that.

1 Output register:
    OUT (111)

    This is where the output of all R type instructions
    are stored, except MOV, which doesn't have an output.

1 Parity bit register:
    PAR

    This is always equal to ^OUT.

Instructions:

str r1, r0

Stores the value in r1 to mem[r0].

ldr r1, r0

Loads the value in mem[r0] to r1.

mov r1, r0

Moves the value in r0 to r1.

xor r1, r0

Sets OUT to the bitwise XOR between r1 and r0. Uses AI register!
"""

import re
import sys


# xor reg1, reg0
def decode_xor(reg1, reg0):
    # NAND r0  r1
    # MOV  AI  OUT
    # NAND r0  AI
    # MOV  AI  OUT
    # NAND r0  r1
    # NAND OUT r1
    # NAND OUT AI
    ops = [
        f"nand {reg1}, {reg0}",
        f"mov r5, OUT",
        f"nand {reg1}, r5",
        f"mov r5, OUT",
        f"nand {reg1}, {reg0}",
        f"nand OUT, {reg0}",
        f"nand OUT, r5",
    ]
    return "".join(decode(line) for line in ops)


def decode_mov_imm(match):
    op, reg1, imm = match.groups()
    assert op == "mov"
    ops = [
        f"set {imm}",
        f"mov {reg1}, out",
    ]
    return "".join(decode(op) for op in ops)


def decode_and(reg1, reg0):
    ops = [
        f"nand {reg1}, {reg0}",
        f"nand out, out",
    ]
    return "".join(decode(op) for op in ops)


def decode_orr(reg1, reg0):
    ops = [
        f"nand {reg1}, {reg1}",
        f"mov r5, OUT",
        f"nand {reg0}, {reg0}",
        f"nand r5, OUT",
    ]
    return "".join(decode(op) for op in ops)


r_ops = {
    "add": "000",
    "rrot": "001",
    "nand": "010",
    "ldr": "011",
    "str": "100",
    "mov": "101",
    "beq": "110",
}
pseudo_ops = {"xor": decode_xor, "and": decode_and, "orr": decode_orr}
i_ops = {"set": "111"}
registers = {
    "r0": "000",
    "r1": "001",
    "r2": "010",
    "r3": "011",
    "r4": "100",
    "r5": "101",
    "par": "110",
    "out": "111",
}

# some whitespace
pre = r"^\s*"
# whitespace, followed by optional inline comment
post = r"\s*(?:(?:\/\/|#|;).*)?$"
# base pattern for each type of instruction
r_re_str = r"(\w+)\s+(\w+),?\s+(\w+)"
set_re_str = r"(\w+)\s+(\w+)"
# regular expressions
r_re = re.compile(pre + r_re_str + post)
i_re = re.compile(pre + set_re_str + post)
label_re = re.compile(pre + r"([_\w]+):" + post)
decimal = re.compile(r"\d+")

# mapping from brach label to pc value
branches: dict[str, int] = {}
# values to put in LUT if necessary
lut: dict[int, int] = {}
pc = 0
branch_counter = 0


def decode(line: str) -> str:
    r_match = r_re.match(line)
    i_match = i_re.match(line)
    label_match = label_re.match(line)

    if r_match is not None:
        op, r1, r0 = r_match.groups()

        if op == "mov" and decimal.match(r0):
            return decode_mov_imm(r_match)

        # expand into native operations
        pf = pseudo_ops.get(op)
        if pf is not None:
            return pf(r1, r0)

        return decode_r(r_match)
    elif i_match is not None:
        return decode_i(i_match)
    elif label_match is not None:
        label_name = label_match.group(1)
        if label_name in branches:
            raise Exception(f"Label {label_name} already defined")
        branches[label_name] = pc
        return ""
    else:
        raise Exception(f"No instruction found for {line = }")


def decode_r(match: re.Match) -> str:
    global pc
    op, reg1, reg0 = map(str.lower, match.groups())
    op_bin = r_ops.get(op)
    if op_bin is None:
        raise Exception(f'invalid op "{op}"')

    reg1_bin = registers.get(reg1)
    if reg1_bin is None:
        raise Exception(f'invalid reg "{reg1}"')

    reg0_bin = registers.get(reg0)
    if reg0_bin is None:
        raise Exception(f'invalid reg "{reg0}"')

    pc += 1
    return f"{op_bin}{reg1_bin}{reg0_bin}\n"


def decode_i(match: re.Match) -> str:
    """The only I-type instruction is set."""
    global pc
    op, imm_str = match.groups()
    if imm_str.isdigit():
        # e.g. set 32
        imm = int(imm_str)
        if imm < 0 or imm > 63:
            raise ValueError("Input integer must be between 0 and 63")

        bin = format(imm, "06b")
    else:
        # setting a label
        # e.g. set loop_end
        bin = f"{{{imm_str}}}"

    op_bin = i_ops.get(op)
    if op_bin is None:
        raise Exception(f'invalid op "{op}"')
    pc += 1
    return f"{op_bin}{bin}\n"


def to_signed_bin(number: int) -> str:
    if -32 <= number <= 31:
        if number >= 0:
            binary_representation = format(number, "06b")
        else:
            abs_value = abs(number)
            inverted_bits = "".join(
                "1" if bit == "0" else "0" for bit in format(abs_value, "06b")
            )
            inverted_integer = int(inverted_bits, 2) + 1
            binary_representation = format(inverted_integer, "06b")
        assert len(binary_representation) == 6
        return binary_representation
    else:
        raise ValueError("Number is out of the valid range for a 6-bit signed integer.")


label_extract = re.compile(r"\{([_\w]+)\}")


def process_branch(bin_line: str, pc: int) -> tuple[str, int]:
    global branch_counter

    if bin_line.startswith("#") or len(bin_line.strip()) == 0:
        return bin_line, pc

    match = label_extract.search(bin_line)
    if match is None:
        return bin_line, pc + 1

    label = match.group(1)
    abs_position_of_label = branches.get(label)
    if abs_position_of_label is None:
        raise Exception(f"Could not find location of branch {label = }")

    relative_branch_dist = abs_position_of_label - pc
    if not LUT_ENABLED:
        bin = to_signed_bin(relative_branch_dist)
    else:
        assert 0 <= branch_counter < 64, "too many branches to fit in 6 bits"
        bin = format(branch_counter, "06b")
        lut[branch_counter] = relative_branch_dist
        branch_counter += 1

    newline = label_extract.sub(bin, bin_line)
    return newline, pc + 1


def main():
    global LUT_ENABLED
    LUT_ENABLED = True

    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} INPUT_ASM [OUTPUT_BINARY]")
        return

    if len(sys.argv) == 2:
        debug = True
        outfile = sys.stdout
    else:
        debug = False
        outfile = open(sys.argv[2], "w")

    out_lines: list[str] = []
    with open(sys.argv[1]) as asm:
        for line in asm:
            if line.startswith(("#", "//", ";")) or len(line.strip()) == 0:
                continue
            bin = decode(line)
            if not debug:
                out_lines.extend(bin.split("\n"))
            else:
                out_lines.append(f"# {line.strip()}")
                out_lines.extend(bin.split("\n"))

    # remove empty strings
    out_lines = [s for s in out_lines if len(s) > 0]
    final_lines = []
    curr_pc = 0
    for line in out_lines:
        newline, curr_pc = process_branch(line, curr_pc)
        final_lines.append(newline)

    outfile.write("\n".join(final_lines))
    if LUT_ENABLED:
        cases = "\n".join(
            f"        {num}: target = {rel_addr};" for num, rel_addr in lut.items()
        )
        print(
            f"""
Values to put in PC_LUT.sv:
    
always_comb
    case (addr)
{cases}
        default: target = 'b0;  // hold PC  
    endcase
        """,
            file=sys.stderr,
        )


if __name__ == "__main__":
    main()
