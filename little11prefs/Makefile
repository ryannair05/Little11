include $(THEOS)/makefiles/common.mk

ARCHS = arm64

BUNDLE_NAME = little11prefs
little11prefs_FILES = L11PrefsListController.m
little11prefs_INSTALL_PATH = /Library/PreferenceBundles
little11prefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/little11prefs.plist$(ECHO_END)
