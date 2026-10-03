TARGET := iphone:clang:latest:15.0
ARCHS := arm64e

THEOS_PACKAGE_SCHEME := roothide
FINALPACKAGE := 1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME := Caro
Caro_FILES := main.m AppDelegate.m RootViewController.m CaroBoardView.m
Caro_FRAMEWORKS := UIKit CoreGraphics QuartzCore AudioToolbox
Caro_CFLAGS := -fobjc-arc -Wno-unused-variable -Wno-unused-function

include $(THEOS_MAKE_PATH)/application.mk
