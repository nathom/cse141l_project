# 9 bit processor

## Using the assembler

Make sure you have python3 installed. Write a script in LEAP asm, and save
it as prog.s. To get the debug output, run

```
python asm.py prog.s
```

![](README_resources/yhsjimbeddlnuxxtjdbkzgchgbjnlaaj.jpg)

To output the clean machine code to a file called `mach_code.txt` run

```
python asm.py prog.s mach_code.txt
```

The output should show what values to put in `PC_LUT.sv`.

## Running the given test programs

If you just want preassembled code to run, use the `prog[n]_mach_code.txt` files, which
are compiled versions of the assembly code in `program[n].s`. The values in `PC_LUT.sv`
have been updated so that all 3 of these can be run without changing it's contents.


For example, if you want to run `program1.s`, do the following:

1. Copy `prog1_mach_code.txt` to `src/mach_code.txt`
2. Verify that the path in `instr_ROM` points to `src/mach_code.txt` on your machine
3. Set `prog1_tb.sv` to be the testbench in quartus
4. Simulate the testbench in Modelsim
