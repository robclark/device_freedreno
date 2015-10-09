#
# Copyright 2014 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ifeq ($(TARGET_PREBUILT_KERNEL),)
LOCAL_KERNEL := device/freedreno/ifc6410-kernel/kernel
else
LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
endif

PRODUCT_DEFAULT_PROPERTY_OVERRIDES := \
	ro.sf.lcd_density=180 \
	dalvik.vm.heapsize=48m \

PRODUCT_COPY_FILES := \
	$(foreach f,$(wildcard $(LOCAL_PATH)/root/*),$(f):$(subst $(LOCAL_PATH)/,,$(f))) \
	$(LOCAL_PATH)/media_codecs.xml:system/etc/media_codecs.xml \
	$(LOCAL_PATH)/media_profiles.xml:system/etc/media_profiles.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
	frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
	$(LOCAL_PATH)/bootimg.cfg:bootimg.cfg \
	$(LOCAL_KERNEL):kernel

# firmware distributed separately, copy these files from your device and
# use ADRENO_FIRMWARE=path/to/firmware/directory on the make cmdline:
PRODUCT_COPY_FILES += \
	$(ADRENO_FIRMWARE)/a300_pfp.fw:root/lib/firmware/a300_pfp.fw \
	$(ADRENO_FIRMWARE)/a300_pm4.fw:root/lib/firmware/a300_pm4.fw \

# Need AppWidget permission to prevent from Launcher's crash.
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.software.app_widgets.xml:system/etc/permissions/android.software.app_widgets.xml

$(call inherit-product-if-exists, vendor/freedreno/ifc6410/device-vendor.mk)


PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG := normal large xlarge mdpi hdpi
PRODUCT_AAPT_PREF_CONFIG := mdpi

DEVICE_PACKAGE_OVERLAYS := $(LOCAL_PATH)/overlay

# Get the hardware acceleration libraries
$(call inherit-product-if-exists,$(LOCAL_PATH)/gpu/gpu_mesa.mk)

PRODUCT_PACKAGES += \
	Trebuchet \

