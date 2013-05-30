# !/bin/bash

cd gera_rom/
./generate_rom.py teste.asm
cp rom32.vhd ../
cd ..
cat rom32.vhd
make sim
gtkwave mips.vcd &
