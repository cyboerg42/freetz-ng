$(call PKG_INIT_BIN, 5.2.6)
$(PKG)_DIR:=$(subst -$($(PKG)_VERSION),,$($(PKG)_DIR))
$(PKG)_SOURCE:=unrarsrc-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=86736fdc652dcbedddac6ac1dff3115a
$(PKG)_SITE:=http://www.rarlab.com/rar

$(PKG)_BINARY:=$($(PKG)_DIR)/unrar
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/unrar

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UNRAR_STATIC
ifeq ($(strip $(FREETZ_PACKAGE_UNRAR_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_UCLIBC_0_9_28
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_UCLIBC_0_9_29
ifeq ($(strip $(or $(FREETZ_TARGET_UCLIBC_0_9_28),$(FREETZ_TARGET_UCLIBC_0_9_29))),y)
$(PKG)_DEFINES += -DVFWPRINTF_WORKAROUND_REQUIRED
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UNRAR_DIR) -f makefile \
		CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CFLAGS) -fno-rtti -fno-exceptions" \
		DEFINES="$(UNRAR_DEFINES)" \
		LDFLAGS="$(UNRAR_LDFLAGS)" \
		STRIP=true

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UNRAR_DIR) -f makefile clean

$(pkg)-uninstall:
	$(RM) $(UNRAR_TARGET_BINARY)

$(PKG_FINISH)
