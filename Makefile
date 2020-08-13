THEOS_DEVICE_IP = 192.168.1.168

FINALPACKAGE = 1

export TARGET = iphone:13.5:13.0
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc -O3

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Little11SpringBoard Little11UIKit
Little11SpringBoard_FILES = TweakSpring.xm
Little11UIKit_FILES = TweakUI.xm
Little11UIKit_LIBRARIES = MobileGestalt

ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Facebook"
SUBPROJECTS += little11prefs
include $(THEOS_MAKE_PATH)/aggregate.mk