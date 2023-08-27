import re

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
test_line = "add r1, r0"
test_line2 = "set 1123"
r_re = re.compile(r"\s*(\w+)\s+(\w+),?\s+(\w+)\s*")
i_re = re.compile(r"\s*(\w+)\s+(\d+)\s*")


def decode(line: str) -> str:
    r_match = r_re.match(line)
    i_match = i_re.match(line)

    if r_match is not None and i_match is not None:
        raise Exception(f"Ambiguous instruction found for {line=}")
    elif r_match is None and i_match is None:
        raise Exception(f"No instruction found for {line=}")

    if r_match is not None:
        return decode_r(r_match, line)
    if i_match is not None:
        return decode_i(i_match, line)


def decode_r(match: re.Match) -> str:
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

    return f"{op_bin}{reg1_bin}{reg0_bin}"


def decode_i(match: re.Match) -> str:
    op, imm_str = match.groups()
    imm = int(imm_str)
    if imm < 0 or imm > 63:
        raise ValueError("Input integer must be between 0 and 63")

    bin = format(imm, "06b")

    op_bin = i_ops.get(op)
    if op_bin is None:
        raise Exception(f'invalid op "{op}"')
    return f"{op_bin}{bin}"
