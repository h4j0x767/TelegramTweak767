TARGET := iphone:clang:latest:14.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SuperGoalTweak

SuperGoalTweak_FILES = Tweak.x
SuperGoalTweak_CFLAGS = -fobjc-arc
SuperGoalTweak_LDFLAGS = -lsubstrate

include $(THEOS_MAKE_PATH)/tweak.mk
