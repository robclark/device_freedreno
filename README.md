# building android:

The following describes how to build android-x86 with freedreno FOSS graphics driver for Inforce ifc6410 board with upstream kernel (currently 4.2).  This should be a useful starting point for adding additional snapdragon devices.

Note: paths below assume checking things out under `$HOME/src/android`, so following layout

  * `$HOME`
    * `src`
       * `android`   <-- directory under which you'll checkout android and kernel
          * `lollipop-x86`
          * `kernel`
          * `firmware`

Note: so far, afaict, firmware is not redistributable.  Recommendation is to copy firmware that came on device (in particular `a300_pfp.fw` and `a300_pm4.pfp` to `$HOME/src/android/firmare/` which will be referenced in later build steps.

## get the sources:

### get android sources:

	mkdir -p $HOME/src/android
	cd $HOME/src/android
	mkdir lollipop-x86
	cd lollipip-x86
	repo init --depth=1 -u http://git.android-x86.org/manifest -b lollipop-x86 -g default,arm,pdk,-darwin
	repo sync -j16

NOTE: there is a sourceforge mirror if git.android-x86.org is having problems.  Use instead:

	repo init --depth=1 -u http://git.code.sf.net/p/android-x86/manifest -b lollipop-x86 -g default,arm,pdk,-darwin

local manifests (for now until everything is upstream).  Copy this to `$HOME/src/android/lollipop-x86/.repo/local_manifests/freedreno.xml`

	<?xml version="1.0" encoding="UTF-8"?>
	<manifest>
	  <remote name="upstream-drm" fetch="git://anongit.freedesktop.org/git/mesa/drm"/>
	  <remote name="freedreno-mesa" fetch="https://github.com/freedreno/mesa.git"/>
	  <remote name="freedreno-gralloc" fetch="https://github.com/robclark/drm_gralloc.git"/>
	  <remote name="freedreno-device" fetch="https://github.com/robclark/device_freedreno.git"/>
	  <remove-project name="platform/external/mesa3d"/>
	  <remove-project name="platform/external/mesa"/>
	  <remove-project name="platform/external/drm"/>
	  <remove-project name="platform/hardware/drm_gralloc"/>
	  <project name="mesa" path="hardware/mesa/" remote="freedreno-mesa" revision="android-prime-rebase"/>
	  <project name="drm_gralloc" path="hardware/drm_gralloc" remote="freedreno-gralloc" revision="freedreno"/>
	  <project name="drm" path="hardware/drm" remote="upstream-drm" revision="master"/>
	  <project name="freedreno" path="device/freedreno" remote="freedreno-device" revision="master"/>
	</manifest>

NOTE: latest upstream libdrm used.  We need to merge drm_gralloc into mesa (since it already uses a lot of internal mesa APIs), and after that try to upstream patches needed for freedreno.  So eventually separate remote for drm_gralloc will be dropped.

and then:

	repo sync -j16

#### apply patches:

There are a couple patches still required:

##### fix confusion about removable storage (still needed?  better fix?)

	cd frameworks/base
	patch -p1 < ../../device/freedreno/patches/0001-don-t-be-confused-about-removable-storage.patch
	cd -

##### strip out parens in `ro.hardware` (otherwise it ends up as "qualcomm(flatteneddevicetree)" and the parens confuse a lot of things:

	cd system/core
	patch -p1 < ../../device/freedreno/patches/0001-strip-parens-from-hardware-name.patch
	cd -

### get kernel sources

	cd $HOME/src/android
	TODO grab linaro integration branch and ?? defconfig ??

## build

### kernel

	cd $HOME/src/android
	cd kernel
	make ARCH=arm CROSS_COMPILE=$HOME/src/android/lollipop-x86/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi- -j30 zImage dtbs
	cat arch/arm/boot/zImage arch/arm/boot/dts/qcom-apq8064-ifc6410.dtb > zImage-dtb

### android:

	cd $HOME/src/lollipop-x86
	source ./build/envsetup.sh
	lunch ifc6410-userdebug
	make -j30 TARGET_PREBUILT_KERNEL=$HOME/src/android/kernel/zImage-dtb ADRENO_FIRMWARE=$HOME/src/android/firmware/

... and wait...

Need to figure out how to make this step automatic, but for now you need to manually create the boot.img:

	cd out/target/product/ifc6410
	abootimg --create boot.img -k kernel -f bootimg.cfg -r ramdisk.img
	cd -

Flash boot and system partition:

	cd out/target/product/ifc6410
	fastboot flash boot boot.img
	fastboot flash system system.img
	cd -

## Known Issuses

 * somehow not loading gralloc.drm.so... workaround is to `cp /system/lib/hw/gralloc.drm.so /system/lib/hw/gralloc.default.so`
 * graphical glitches.. possibly caused by not having support for explicit sync and fence objects??
 * launcher crashes.. to be debugged
 * settings screen shows GL_VENDOR/etc as null.. possibly missing an eglMakeCurrent() call?

