THEOS_DEVICE_IP = 192.168.1.168

FINALPACKAGE=1

export TARGET = iphone:clang:latest:12.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Little11
Little11_FILES = Tweak.xm
Little11_LIBRARIES = MobileGestalt
Little11_CFLAGS = -fobjc-arc
ARCHS = arm64

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += little11prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
