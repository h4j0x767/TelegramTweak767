TARGET := iphone:clang:latest:14.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TelegramTweak767

TelegramTweak767_FILES = Tweak.x
TelegramTweak767_CFLAGS = -fobjc-arc
TelegramTweak767_LDFLAGS = -lsubstrate

include $(THEOS_MAKE_PATH)/tweak.mk
