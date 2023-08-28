"""
An assembler for the LEAP architecture.
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

r_re = re.compile(r"\s*(\w+)\s+(\w+),?\s+(\w+)\s*")
i_re = re.compile(r"\s*(\w+)\s+(\d+)\s*")
decimal = re.compile(r"\d+")


def decode(line: str) -> str:
    r_match = r_re.match(line)
    i_match = i_re.match(line)

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
    else:
        raise Exception(f"No instruction found for {line = }")


def decode_r(match: re.Match) -> str:
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

    return f"{op_bin}{reg1_bin}{reg0_bin}\n"


def decode_i(match: re.Match) -> str:
    op, imm_str = match.groups()
    imm = int(imm_str)
    if imm < 0 or imm > 63:
        raise ValueError("Input integer must be between 0 and 63")

    bin = format(imm, "06b")

    op_bin = i_ops.get(op)
    if op_bin is None:
        raise Exception(f'invalid op "{op}"')
    return f"{op_bin}{bin}\n"


def main():
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} INPUT_ASM [OUTPUT_BINARY]")
        return

    if len(sys.argv) == 2:
        debug = True
        outfile = sys.stdout
    else:
        debug = False
        outfile = open(sys.argv[2], "w")

    with open(sys.argv[1]) as asm:
        for line in asm:
            if line.startswith(("#", "//")):
                continue
            bin = decode(line)
            if not debug:
                outfile.write(bin)
            else:
                outfile.write(f"# {line.strip()}\n{bin}")


if __name__ == "__main__":
    main()
