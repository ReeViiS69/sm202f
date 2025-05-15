#!/bin/bash
set -e

# Pfade und Namen
KCONFIG_FILE="kernel/Kconfig.ksu"
INCLUDE_TARGET="arch/arm64/Kconfig"
DEFCONFIG_NAME="exynos7885-a20e_defconfig"

echo "Erstelle $KCONFIG_FILE ..."

mkdir -p "$(dirname "$KCONFIG_FILE")"

cat > "$KCONFIG_FILE" << 'EOF'
menu "KSU SUSFS Configuration"

config KSU
    bool "Enable KSU core"
    default y

config KSU_WITH_KPROBES
    bool "Enable KSU with KProbes support"
    depends on KSU
    default n

config KSU_SUSFS
    bool "Enable KSU SUSFS"
    depends on KSU
    default y

config KSU_SUSFS_HAS_MAGIC_MOUNT
    bool "Support for magic mount path"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SUS_PATH
    bool "Enable SUS path support"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SUS_MOUNT
    bool "Enable SUS mount support"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT
    bool "Auto add SUS KSU default mount"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT
    bool "Auto add SUS bind mount"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SUS_KSTAT
    bool "Enable SUS kstat"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SUS_OVERLAYFS
    bool "Enable SUS overlayfs"
    depends on KSU_SUSFS
    default n

config KSU_SUSFS_TRY_UMOUNT
    bool "Enable try umount support"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT
    bool "Auto add try umount for bind mount"
    depends on KSU_SUSFS_TRY_UMOUNT
    default y

config KSU_SUSFS_SPOOF_UNAME
    bool "Enable uname spoofing"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_ENABLE_LOG
    bool "Enable SUSFS logging"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS
    bool "Hide SUSFS symbols"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG
    bool "Spoof cmdline or bootconfig"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_OPEN_REDIRECT
    bool "Enable open redirect"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SUS_SU
    bool "Enable SUS su"
    depends on KSU_SUSFS
    default n

endmenu
EOF

echo " Kconfig geschrieben: $KCONFIG_FILE"

# Prüfen, ob die Datei bereits eingebunden ist
if ! grep -qF "$KCONFIG_FILE" "$INCLUDE_TARGET"; then
    echo "🔧 Binde $KCONFIG_FILE in $INCLUDE_TARGET ein ..."
    echo "source \"$KCONFIG_FILE\"" >> "$INCLUDE_TARGET"
else
    echo " $KCONFIG_FILE ist bereits eingebunden."
fi

#Konfiguration setzen
# echo " Aktiviere Optionen in .config ..."
# make ARCH=arm64 "$DEFCONFIG_NAME"

# SCONFIGS=(
  # CONFIG_KSU
  # CONFIG_KSU_WITH_KPROBES
  # CONFIG_KSU_SUSFS
  # CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT
  # CONFIG_KSU_SUSFS_SUS_PATH
  # CONFIG_KSU_SUSFS_SUS_MOUNT
  # CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT
  # CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT
  # CONFIG_KSU_SUSFS_SUS_KSTAT
  # CONFIG_KSU_SUSFS_SUS_OVERLAYFS
  # CONFIG_KSU_SUSFS_TRY_UMOUNT
  # CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT
  # CONFIG_KSU_SUSFS_SPOOF_UNAME
  # CONFIG_KSU_SUSFS_ENABLE_LOG
  # CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS
  # CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG
  # CONFIG_KSU_SUSFS_OPEN_REDIRECT
  # CONFIG_KSU_SUSFS_SUS_SU
  # CONFIG_TMPFS_XATTR
  # CONFIG_TMPFS_POSIX_ACL
# )

# for cfg in "${SCONFIGS[@]}"; do
  # scripts/config -e "$cfg" || echo " Warnung: $cfg konnte nicht gesetzt werden"
# done

# make ARCH=arm64 olddefconfig

# echo "Speichere als defconfig ..."
# make ARCH=arm64 savedefconfig
# cp defconfig "arch/arm64/configs/${DEFCONFIG_NAME}"

# echo "Fertig! Deine defconfig (${DEFCONFIG_NAME}) wurde aktualisiert."


