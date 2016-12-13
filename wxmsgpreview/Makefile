THEOS_DEVICE_IP = 192.168.199.193
ARCHS = arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WXsightforward
WXsightforward_FILES = Tweak.xm
WXsightforward_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
