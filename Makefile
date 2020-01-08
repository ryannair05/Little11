THEOS_DEVICE_IP = 192.168.1.168

FINALPACKAGE=1

export TARGET = iphone:11.2
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Little11
Little11_FILES = Tweak.xm
Little11_LIBRARIES = MobileGestalt
ARCHS = arm64

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += little11prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
