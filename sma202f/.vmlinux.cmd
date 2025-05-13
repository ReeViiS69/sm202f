cmd_vmlinux := /bin/bash scripts/link-vmlinux.sh ./toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-ld -EL  --no-undefined -X -pie -Bsymbolic --build-id
