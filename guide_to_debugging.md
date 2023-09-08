# Guide to Debugging Assembly in Modelsim/Quartus

## Making sure the correct program is running

Every time a simulation is run, modelsim reads the current state of
`src/mach_code.txt`. So, if you want your assembly to run, make sure
its compiled machine code is in that location.

```bash
# may have to replace / with \ on windows idk
python asm.py my_asm.s src/mach_code.txt
```

After running this, if there are no exceptions, the assembler should put the machine
code of `my_asm.s` into `src/mach_code.txt`. It should also display something like 
the following in the console:

```
always_comb
    case (addr)
        0: target = 259;
        1: target = -260;
        default: target = 'b0;  // hold PC
    endcase

There are 268 instructions. Ensure
the done flag is not raised before pc hits 268.
```
