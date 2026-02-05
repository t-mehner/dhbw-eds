# vhdl_rom_to_coe

Minimal converter for extracting 8-bit ROM contents from a VHDL source file and writing a Xilinx `.coe` initialisation file (radix 2).

## What it does

- Scans the input VHDL text for ROM lines of the form:
  `"01111110", -- optional comment`
- Writes a `.coe` file with:
  - `memory_initialization_radix=2;`
  - `memory_initialization_vector=`
  - one 8-bit entry per line
- Preserves VHDL `-- ...` comments by converting them into COE-style `; ...` inline comments.

## Usage

```bash
python vhdl_rom_to_coe.py input.vhdl out.coe
````

## Expected input format

Your `input.vhdl` should contain the ROM initialisation block with lines like:

```vhdl
"01111110", -- 2  ******
"10000001", -- 3 *      *
```

Other lines are ignored.

## Notes

* The script only matches 8-bit binary literals (`[01]{8}`).
* A trailing comma in VHDL is accepted; the last COE entry is terminated with `;`, all others with `,`.
* Comments are best kept ASCII-only if you want maximum tool compatibility.

## Attribution / Source

The original font ROM VHDL this was extracted from is:

[https://github.com/MadLittleMods/FP-V-GA-Text/blob/master/vgaText/fontROM.vhd](https://github.com/MadLittleMods/FP-V-GA-Text/blob/master/vgaText/fontROM.vhd)

This repository/script only converts/extracts the ROM contents into `.coe` format for convenient use in Xilinx flows.

```
