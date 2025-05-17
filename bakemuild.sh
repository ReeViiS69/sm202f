#!/bin/bash
#initkernel
rm -rf sma202f
mkdir sma202f
tar -xzf Kernel.tar.gz -C sma202f
cd sma202f
#endinitkernel
#fixestoolchain
sed -i '/^YYLTYPE yylloc$/s/^YYLTYPE yylloc$/extern YYLTYPE yylloc/' scripts/dtc/dtc-parser.tab.c_shipped
sed -i $'/def print_deprecation_warning(self):/,/file=sys.stderr)/c\
  def print_deprecation_warning(self):\
\tpass' ./toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-g??
#endfixestoolchain
#ksun
chmod u+w ./drivers/Makefile
curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -s v1.0.6
#endksun
#suspatches
if [ ! -f "./syscall_hooks.patch" ]; then
	cp ../kernel_patches/fs/* ./fs/
	cp ../kernel_patches/include/linux/* ./include/linux/
	cp ../kernel_patches/50_add_susfs_in_kernel-4.9.patch ./
	cp ../wildkernel_patches/next/syscall_hooks.patch ./
	cp ../wildkernel_patches/next/0001-kernel-patch-susfs-v1.5.5-to-KernelSU-Next-v1.0.5.patch ./KernelSU-Next/
	cd ./KernelSU-Next/
	patch -p1 --forward < 0001-kernel-patch-susfs-v1.5.5-to-KernelSU-Next-v1.0.5.patch
	cd ..
	chmod u+w fs/Makefile fs/dcache.c fs/namei.c fs/namespace.c fs/notify/fdinfo.c fs/overlayfs/inode.c fs/overlayfs/overlayfs.h fs/overlayfs/readdir.c fs/overlayfs/super.c fs/proc/cmdline.c fs/proc/fd.c fs/proc/task_mmu.c fs/proc_namespace.c fs/readdir.c fs/stat.c fs/statfs.c include/linux/mount.h include/linux/sched.h kernel/kallsyms.c kernel/sys.c
	patch -p1 < 50_add_susfs_in_kernel-4.9.patch
	#susfs adjustments for samsung
	cd ./fs/
	cp ../../wildkernel_patches/next/susfsmultihotfix.patch ./
	patch -p1 < susfsmultihotfix.patch
	cd ..
	sed -i 's|#include <linux/bits.h>|#include <linux/bitops.h>|' include/linux/susfs_def.h
	#endsusfs adjustments for samsung
	chmod u+w fs/exec.c fs/open.c fs/read_write.c drivers/input/input.c drivers/tty/pty.c
	patch -p1 -F 3 < syscall_hooks.patch
	#ksun adjustments for samsung
	cd ./drivers/
	cp ../../wildkernel_patches/next/ksunhotfix.patch ./
	patch -p1 < ksunhotfix.patch
	cd ..
fi
#endsusfspatches
#configsksunsusfs
chmod u+w ./arch/arm64/Kconfig
chmod +x ../setup_ksun_kconfig.sh
../setup_ksun_kconfig.sh
CONFIG_FILE="./arch/arm64/configs/exynos7885-a20e_defconfig"
CONFIGS=(
  "CONFIG_KSU=y"
  "CONFIG_KSU_WITH_KPROBES=n"
  "CONFIG_KSU_SUSFS=y"
  "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y"
  "CONFIG_KSU_SUSFS_SUS_PATH=y"
  "CONFIG_KSU_SUSFS_SUS_MOUNT=y"
  "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y"
  "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y"
  "CONFIG_KSU_SUSFS_SUS_KSTAT=y"
  "CONFIG_KSU_SUSFS_SUS_OVERLAYFS=n"
  "CONFIG_KSU_SUSFS_TRY_UMOUNT=y"
  "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y"
  "CONFIG_KSU_SUSFS_SPOOF_UNAME=y"
  "CONFIG_KSU_SUSFS_ENABLE_LOG=y"
  "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y"
  "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y"
  "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y"
  "CONFIG_KSU_SUSFS_SUS_SU=n"
  "CONFIG_TMPFS_XATTR=y"
  "CONFIG_TMPFS_POSIX_ACL=y"
)
for config in "${CONFIGS[@]}"; do
  key=$(echo "$config" | cut -d= -f1)
  if grep -q "^$key=" "$CONFIG_FILE"; then
    sed -i "s|^$key=.*|$config|" "$CONFIG_FILE"
  else
    echo "$config" >> "$CONFIG_FILE"
  fi
done
#endconfigsksunsusfs
#tempfixes
cp ../namei.c.cgpt ./fs/namei.c
cp ../susfs.c.working ./fs/susfs.c
cp ../open.c.working ./fs/open.c
cp ../read_write.c.working ./fs/read_write.c
cp ../apk_sign.c.working ./KernelSU-Next/kernel/apk_sign.c
sed -i '/ksu_handle_execveat_ksud/ s/int[[:space:]]*\*[[:space:]]*fd/int fd/' drivers/kernelsu/ksud.c
#modulesnotworkingfix
cp ../namespace.c.chiteroman ./fs/namespace.c
chmod u+w ./security/selinux/hooks.c
cp ../hooks.c.f19f ./security/selinux/hooks.c
cp ../core_hook.c.working ./drivers/kernelsu/core_hook.c
#endtempfixes
export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export ARCH=arm64
#removesamsungsecurity may need to adjust; cant get secure folder working cuz /data is encypted?!
sed -i -E '/^CONFIG_(TIMA(_LKMAUTH|_LKM_BLOCK)?|UH(_RKP)?|RKP_(KDP|NS_PROT|DMAP_PROT)|FIVE(_(CERT_USER|DEFAULT_HASH(_SHA1)?)?)?|SECURITY_DEFEX|PROCA)=/ { s/^(CONFIG_[A-Z0-9_]+)="[^"]*".*$/# \1 is not set/; s/^(CONFIG_[A-Z0-9_]+)=y$/\1=n/ }' ./arch/arm64/configs/exynos7885-a20e_defconfig
make exynos7885-a20e_defconfig
#setspoofbuild
chmod u+w ./scripts/setlocalversion ./scripts/mkcompile_h
perl -pi -e 's{^UTS_VERSION="\$UTS_VERSION\s+\$CONFIG_FLAGS\s+\$TIMESTAMP"}{UTS_VERSION="#1 SMP PREEMPT Wed Jun 28 08:22:22 +07 2023"}' ./scripts/mkcompile_h
sed -i '$s|echo "\$res"|echo "-26555245"|' ./scripts/setlocalversion
#ksun adding functions not working
chmod u+w ./fs/internal.h ./kernel/cred.c ./include/linux/cred.h
make
#makebootimg
cd ../maggi/
cp ../sma202f/arch/arm64/boot/Image ./kernel
../magiskboot-linux/x86_64/magiskboot repack ../boot.img boot.img
#certificate.pem is made from included verity_dev_keys.x509
../magiskboot-linux/x86_64/magiskboot sign boot.img ../certificate.pem
