cmd_fs/fat/built-in.o :=  ./toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-ld -EL   -r -o fs/fat/built-in.o fs/fat/fat.o fs/fat/vfat.o fs/fat/msdos.o 
