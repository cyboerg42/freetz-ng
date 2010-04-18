$(call PKG_INIT_BIN, 1.1.26)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/libxslt-$($(PKG)_VERSION)
$(PKG)_SOURCE:=libxslt-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=e61d0364a30146aaa3001296f853b2b9
$(PKG)_SITE:=ftp://xmlsoft.org/libxslt

$(PKG)_BINARY_BUILD_DIR := $($(PKG)_DIR)/$(pkg)/.libs/$(pkg)
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_LIBNAMES_SHORT := libxslt libexslt
$(PKG)_LIBVERSIONS := 1.1.26 0.8.15
$(PKG)_LIBNAMES_LONG :=  $(join $($(PKG)_LIBNAMES_SHORT:%=%.so.),$($(PKG)_LIBVERSIONS))
$(PKG)_LIBS_BUILD_DIR := $(join $($(PKG)_LIBNAMES_SHORT:%=$($(PKG)_DIR)/%/.libs/),$($(PKG)_LIBNAMES_LONG))
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_LIBDIR)/%)

$(PKG)_DEPENDS_ON += libxml2

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-plugins=no
$(PKG)_CONFIGURE_OPTIONS += --with-python=no
$(PKG)_CONFIGURE_OPTIONS += --with-crypto=no
$(PKG)_CONFIGURE_OPTIONS += --with-debugger=no
$(PKG)_CONFIGURE_OPTIONS += --with-debug=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(XSLTPROC_DIR) \
		all

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(XSLTPROC_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.la) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/xslt-config

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(XSLTPROC_DIR) clean
	$(RM) -r \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.*) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%-plugins) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/%) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/xslt*

$(pkg)-uninstall:
	$(RM) $(XSLTPROC_BINARY_TARGET_DIR) $(XSLTPROC_LIBNAMES_SHORT:%=$(XSLTPROC_TARGET_LIBDIR)/%.so*)

$(PKG_FINISH)
