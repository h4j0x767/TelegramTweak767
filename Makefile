THEOS_DEVICE_IP = 127.0.0.1
ARCHS = arm64
TARGET = iphone:clang:16.0:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TelegramTweak767

TelegramTweak767_FILES = Tweak.x
TelegramTweak767_CFLAGS = -fobjc-arc
TelegramTweak767_FRAMEWORKS = UIKit Foundation
TelegramTweak767_PRIVATE_FRAMEWORKS =
TelegramTweak767_LIBRARIES =

# Target the Telegram app bundle
TelegramTweak767_BUNDLE_ID = ph.telegra.Telegraph

include $(THEOS_MAKE_PATH)/tweak.mk
