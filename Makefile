TARGET := iphone:clang:10.3:9.0
ARCHS := armv7
include $(THEOS)/makefiles/common.mk
APPLICATION_NAME := Raptor
Raptor_FILES := Raptor/Sources/main.m Raptor/Sources/AppDelegate.m Raptor/Sources/RootViewController.m
Raptor_FRAMEWORKS := UIKit Foundation AVFoundation MediaPlayer
Raptor_CFLAGS := -fobjc-arc -Wno-deprecated-declarations
Raptor_RESOURCE_DIRS := Raptor/Resources
include $(THEOS_MAKE_PATH)/application.mk
