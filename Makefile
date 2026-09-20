export THEOS_PACKAGE_SCHEME = roothide
export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64 arm64e
export GO_EASY_ON_ME = 1

INSTALL_TARGET_PROCESSES = SpringBoard RelaxinTest

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = RelaxinTest
RelaxinTest_FILES = app/main.m app/AppDelegate.m app/RootViewController.m
RelaxinTest_FRAMEWORKS = UIKit Foundation
RelaxinTest_CFLAGS = -fobjc-arc -Wno-unused-variable
RelaxinTest_CODESIGN_FLAGS = -Sentitlements.plist
RelaxinTest_INSTALL_PATH = /Applications

TWEAK_NAME = RelaxinTestTweak
RelaxinTestTweak_FILES = tweak/Tweak.x
RelaxinTestTweak_FRAMEWORKS = UIKit Foundation
RelaxinTestTweak_CFLAGS = -fobjc-arc
RelaxinTestTweak_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS_MAKE_PATH)/application.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "uicache -p /Applications/RelaxinTest.app || true; killall -9 SpringBoard || true"
