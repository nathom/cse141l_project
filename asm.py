import re
import sys

r_ops = {
    "add": "000",
    "rrot": "001",
    "nand": "010",
    "ldr": "011",
    "str": "100",
    "mov": "101",
    "beq": "110",
}
i_ops = {"set": "111"}
registers = {
    "r0": "000",
    "r1": "001",
    "r2": "010",
    "r3": "011",
    "r4": "100",
    "r5": "101",
    "r6": "110",
    "out": "111",
}

r_re = re.compile(r"\s*(\w+)\s+(\w+),?\s+(\w+)\s*")
i_re = re.compile(r"\s*(\w+)\s+(\d+)\s*")


def decode(line: str) -> str:
    r_match = r_re.match(line)
    i_match = i_re.match(line)

    if r_match is not None:
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
        outfile = sys.stdout
    else:
        outfile = open(sys.argv[2], "w")

    with open(sys.argv[1]) as asm:
        for line in asm:
            if line.startswith(("#", "//")):
                continue
            bin = decode(line)
            outfile.write(bin)


if __name__ == "__main__":
    main()
