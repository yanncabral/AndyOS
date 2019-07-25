FPCPARAMS2 = -Aelf -n -O3 -Si -Sc -Sg -Xd -CX -XXs -Rintel -Pi386 -MObjFPC -Fu. -Fucore
FPCPARAMS =-Tlinux -Pi386 -CpPENTIUM2 -Rintel -MObjFPC -Scghi -CX -O3 -XX -l -vewnhibq -n -Filib/i386-linux -Fucore -Fu. -FUlib/i386-linux -FE. -oandy -Aelf
ASPARAMS = --32
LDPARAMS = --gc-sections -s -melf_i386

objects = units/*.o
BinPath = /home/yann/opt/cross/bin/
FPCPath = /home/yann/LazarusIDE/fpc/bin/x86_64-linux/

runFPC:
		i386-elf-as $(ASPARAMS) -o units/loader.o loader.s
		fpc.sh $(FPCPARAMS) andy.lpr -ounits/
		i386-elf-ld $(LDPARAMS) -Tlinker.ld -o mykernel.bin $(objects)
		qemu-system-i386 -kernel mykernel.bin

run:
		$(BinPath)i386-elf-as $(ASPARAMS) -o units/loader.o loader.s
		$(FPCPath)fpc.sh $(FPCPARAMS2) andy.lpr -ounits/
		$(BinPath)i386-elf-ld $(LDPARAMS) -Tlinker.ld -o andy.bin $(objects)
		qemu-system-i386 -kernel andy.bin

