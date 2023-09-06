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
    out (111)

    This is where the output of all R type instructions
    are stored, except MOV, which doesn't have an output.

1 Parity bit register:
    PAR

    This is always equal to ^out.

R-Type Instructions:

str r1, r0

Stores the value in r1 to mem[r0].

ldr r1, r0

Loads the value in mem[r0] to r1.

mov r1, r0

Moves the value in r0 to r1.

xor r1, r0

Sets out to the bitwise XOR between r1 and r0. Uses AI register!

rot r1, r0

Rotates the contents of r1 *right* by r0 spaces. 

I-Type Instructions:

set imm

Sets the out register to imm, a constant value.
"""

import itertools
import re
import sys


# xor reg1, reg0
def decode_xor(reg1, reg0) -> list[str]:
    # NAND r0  r1
    # MOV  AI  out
    # NAND r0  AI
    # MOV  AI  out
    # NAND r0  r1
    # NAND out r1
    # NAND out AI
    invalid_regs = ("out", "r5", "par")
    if reg1 in invalid_regs or reg0 in invalid_regs:
        raise Exception("Cannot use out, r5, or par registers with xor")

    ops = [
        f"nand {reg1}, {reg0}",
        f"mov r5, out",  # r5 = A nand B
        f"nand {reg1}, r5",
        f"mov r5, out",  # r5 = B nand (A nand B)
        f"nand {reg1}, {reg0}",  # out = A nand B
        f"nand out, {reg0}",  # out = A nand (A nand B)
        f"nand out, r5",  # out = (A nand (A nand B)) nand (B nand (A nand B))
    ]

    return list(itertools.chain.from_iterable(decode(line) for line in ops))


def decode_mov_imm(match) -> list[str]:
    op, reg1, imm = match.groups()
    assert op == "mov"

    ops = [
        f"set {imm}",
        f"mov {reg1}, out",
    ]

    return list(itertools.chain.from_iterable(decode(op) for op in ops))


def decode_and(reg1, reg0):
    ops = [
        f"nand {reg1}, {reg0}",
        f"nand out, out",
    ]
    return list(itertools.chain.from_iterable(decode(op) for op in ops))


# Cannot be used if reg0 is OUT
def decode_orr(reg1, reg0):
    if reg0 in ("r5", "out", "par") or reg1 == "r5":
        raise Exception(
            "Second operand cannot be out or par. Both first and second cannot be r5."
        )

    ops = [
        f"nand {reg1}, {reg1}",
        f"mov r5, out",
        f"nand {reg0}, {reg0}",
        f"nand r5, out",
    ]
    return list(itertools.chain.from_iterable(decode(op) for op in ops))


r_ops = {
    "add": "000",
    "rot": "001",
    "nand": "010",
    "ldr": "011",
    "str": "100",
    "mov": "101",
    "beq": "110",
}
pseudo_ops = {"xor": decode_xor, "and": decode_and, "orr": decode_orr}
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
immediate = re.compile(r"(\d+|0b[01]+)")

pc = 0  # program counter
branch_counter = 0  # running count of number of branches

# mapping from brach label to pc value
branches: dict[str, int] = {}
# values to put in LUT if necessary
# mapping from branch_count to relative jump size
lut: dict[int, int] = {}


def decode(line: str) -> list[str]:
    r_match = r_re.match(line)
    i_match = i_re.match(line)
    label_match = label_re.match(line)

    if r_match is not None:
        op, r1, r0 = r_match.groups()
        if op == "mov" and immediate.match(r0) is not None:
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
        return []
    else:
        raise Exception(f"No instruction found for {line = }")


def decode_r(match: re.Match) -> list[str]:
    global pc
    op, reg1, reg0 = match.groups()
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
    return [f"{op_bin}{reg1_bin}{reg0_bin}"]


def decode_i(match: re.Match) -> list[str]:
    """The only I-type instruction is set."""
    global pc
    _, imm_str = match.groups()
    if imm_str.isdigit():
        base = 10
    elif imm_str.startswith("0b"):
        base = 2
    elif imm_str.startswith("0x"):
        base = 16
    else:
        base = None

    if base is not None:
        imm = int(imm_str, base=base)
        if imm < 0 or imm > 255:
            raise ValueError(
                f"Input integer {imm} must be between 0 and 255 to fit in 8 bit reg"
            )
        if imm < 64:
            # we can fit it in the 6 bit immediate
            bin = format(imm, "06b")
        else:
            # 7 to 8 bits
            # shift in top 5 bits
            # then orr with bottom 3 bits
            bin = format(imm, "08b")
            top_5_bits = int(bin[:5], base=2)
            bot_3_bits = int(bin[5:], base=2)
            # ex: 1010_1010
            ops = [
                f"set {top_5_bits}",  # out = 0001_0101
                f"mov r5, out",  # r5 = out
                "set 5",  # out = 5
                "rot r5, out",  # out = r5 rot 5 = 1010_1000
                # now we need to do out | bottom bits
                "nand out, out",  # out = ~out
                "mov r5, out",  # r5 = out
                f"set {bot_3_bits}",  # out = 0000_0010
                "nand out, out",  # out = ~out
                "nand r5, out",  # out = ~(r5 & out)
            ]
            return list(itertools.chain.from_iterable(decode(op) for op in ops))

    else:
        # setting a label
        # e.g. set loop_end
        # will be replaced with either rel addr or pc addr in second pass
        bin = f"{{{imm_str}}}"

    op_bin = "111"  # opcode of set
    pc += 1
    return [f"{op_bin}{bin}"]


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
        print(f"Usage: python {sys.argv[0]} INPUT_ASM [outPUT_BINARY]")
        return

    if len(sys.argv) == 2:
        debug = True
        outfile = sys.stdout
    else:
        debug = False
        outfile = open(sys.argv[2], "w")

    out_lines: list[str] = []
    with open(sys.argv[1]) as asm:
        for i, line in enumerate(asm):
            _line = line.strip().lower()
            if _line.startswith(("#", "//", ";")) or len(_line) == 0:
                continue
            try:
                bin = decode(_line)
            except Exception as e:
                raise Exception(f"Error decoding line {i+1}: {e}") from e

            if not debug:
                out_lines.extend(bin)
            else:
                out_lines.append(f"# {_line}")
                out_lines.extend(bin)

    # remove empty strings
    out_lines = [s for s in out_lines if len(s) > 0]
    final_lines = []
    curr_pc = 0
    for line in out_lines:
        newline, curr_pc = process_branch(line, curr_pc)
        if debug and not newline.startswith("#"):
            newline = f"{curr_pc}: {newline}"
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

There are {curr_pc+1} instructions. Ensure
the done flag is not raised before pc hits {curr_pc+1}.
    """,
            file=sys.stderr,
        )


if __name__ == "__main__":
    main()
