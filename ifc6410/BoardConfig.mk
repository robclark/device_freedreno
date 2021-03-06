# config.mk
#
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true

TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := krait

#SMALLER_FONT_FOOTPRINT := true
#MINIMAL_FONT_FOOTPRINT := true

WITH_DEXPREOPT := true

# Some framework code requires this to enable BT
# For now:
BOARD_HAVE_BLUETOOTH := false
#BOARD_HAVE_BLUETOOTH := true
#BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/generic/common/bluetooth

BOARD_USES_GENERIC_AUDIO := true

BOARD_GPU_DRIVERS := freedreno
BOARD_EGL_CFG := device/generic/common/gpu/egl_mesa.cfg

USE_CAMERA_STUB := true

BUILD_EMULATOR_OPENGL := false
USE_OPENGL_RENDERER := true

BOARD_USE_LEGACY_UI := true
VSYNC_EVENT_PHASE_OFFSET_NS := 0

TARGET_USERIMAGES_USE_EXT4 := true
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 524288000
BOARD_USERDATAIMAGE_PARTITION_SIZE := 576716800
BOARD_CACHEIMAGE_PARTITION_SIZE := 69206016
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 512
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true

BOARD_SEPOLICY_DIRS += build/target/board/generic/sepolicy
BOARD_SEPOLICY_UNION += \
        bootanim.te \
        device.te \
        domain.te \
        file.te \
        file_contexts \
        qemud.te \
        rild.te \
        shell.te \
        surfaceflinger.te \
        system_server.te
