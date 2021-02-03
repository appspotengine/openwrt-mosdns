#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mosdns
PKG_VERSION:=1.3.2
PKG_RELEASE:=1

ifeq ($(ARCH),mipsel)
	MOSDNS_ARCH:=mipsle-softfloat
endif
ifeq ($(ARCH),mips)
	MOSDNS_ARCH:=mips64-hardfloat
endif
ifeq ($(ARCH),x86_64)
	MOSDNS_ARCH:=amd64
endif
ifeq ($(ARCH),arm)
	MOSDNS_ARCH:=arm-7
endif
ifeq ($(ARCH),aarch64)
	MOSDNS_ARCH:=arm64
endif

PKG_LICENSE:=Apache-2.0
PKG_BUILD_DIR:=$(BUILD_DIR)/mosdns-$(PKG_VERSION)
PKG_URL:=https://github.com/IrineSistiana/mosdns.git
PKG_FILE:=mosdns-linux-$(MOSDNS_ARCH)-$(PKG_VERSION).zip

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=mosdns is a programmable DNS forwarder
	DEPENDS:=
	URL:=https://github.com/IrineSistiana/mosdns/releases
endef

define Package/$(PKG_NAME)/description
mosdns is a "programmable" DNS forwarder.
endef


define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	git clone -b v$(PKG_VERSION) $(PKG_URL) $(PKG_BUILD_DIR) 
endef

define Build/Configure
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && CGO_ENABLED=0 GOOS=linux GOARCH=$(MOSDNS_ARCH) go build -ldflags "-s -w -X main.version=$(PKG_VERSION)" -trimpath -o mosdns
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/mosdns
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mosdns $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mosdns-init $(1)/etc/init.d/mosdns-init
	$(INSTALL_DIR) $(1)/etc/mosdns
	$(INSTALL_DATA) ./files/mosdns/* $(1)/etc/mosdns/
endef
$(eval $(call BuildPackage,$(PKG_NAME)))
