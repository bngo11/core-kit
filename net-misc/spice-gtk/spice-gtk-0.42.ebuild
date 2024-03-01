# Distributed under the terms of the GNU General Public License v2
# 🦊 ❤ metatools: {autogen_id}

EAPI=7
PYTHON_COMPAT=( python3+ )
VALA_USE_DEPEND="vapigen"

inherit desktop meson optfeature python-any-r1 readme.gentoo-r1 vala xdg

DESCRIPTION="Set of GObject and Gtk objects for connecting to Spice servers and a client GUI"
HOMEPAGE="https://www.spice-space.org https://cgit.freedesktop.org/spice/spice-gtk/"
SRC_URI="https://www.spice-space.org/download/gtk/spice-gtk-0.42.tar.xz -> spice-gtk-0.42.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="+gtk3 +introspection lz4 mjpeg policykit sasl smartcard usbredir vala wayland webdav"

# TODO:
# * use external pnp.ids as soon as that means not pulling in gnome-desktop
RDEPEND="
	dev-libs/glib:2
	dev-libs/json-glib:0=
	media-libs/gst-plugins-base:1.0
	media-libs/gst-plugins-good:1.0
	media-libs/gstreamer:1.0[introspection?]
	media-libs/opus
	media-libs/libjpeg-turbo:=
	sys-libs/zlib
	x11-libs/cairo
	x11-libs/pixman
	x11-libs/libX11
	gtk3? ( x11-libs/gtk+:3[introspection?] )
	introspection? ( dev-libs/gobject-introspection )
	dev-libs/openssl:=
	lz4? ( app-arch/lz4 )
	sasl? ( dev-libs/cyrus-sasl )
	smartcard? ( app-emulation/qemu[smartcard] )
	usbredir? (
		sys-apps/hwids
		sys-apps/usbredir
		virtual/acl
		virtual/libusb:1
		policykit? (
			sys-auth/polkit
		)
	)
	webdav? (
		net-libs/phodav:=
		net-libs/libsoup:=
	)
"
RDEPEND="${RDEPEND}
	amd64? ( x11-libs/libva:= )
	arm64? ( x11-libs/libva:= )
	x86? ( x11-libs/libva:= )
"
DEPEND="${RDEPEND}
	app-emulation/spice-protocol:=
"
BDEPEND="
	dev-perl/Text-CSV
	sys-devel/gettext
	virtual/pkgconfig
	$(python_gen_any_dep '
		dev-python/six[${PYTHON_USEDEP}]
		dev-python/pyparsing[${PYTHON_USEDEP}]
	')
	vala? ( $(vala_depend) )
"

python_check_deps() {
	python_has_version "dev-python/six[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/pyparsing[${PYTHON_USEDEP}]"
}

src_prepare() {
	default

	python_fix_shebang subprojects/keycodemapdb/tools/keymap-gen

	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_feature gtk3 gtk)
		$(meson_feature introspection)
		$(meson_use mjpeg builtin-mjpeg)
		$(meson_feature policykit polkit)
		$(meson_feature lz4)
		$(meson_feature sasl)
		$(meson_feature smartcard)
		$(meson_feature usbredir)
		$(meson_feature vala vapi)
		$(meson_feature webdav)
		$(meson_feature wayland wayland-protocols)
	)

	if use elibc_musl; then
		emesonargs+=(
			-Dcoroutine=gthread
		)
	fi

	if use usbredir; then
		emesonargs+=(
			-Dusb-acl-helper-dir=/usr/libexec
			-Dusb-ids-path="${EPREFIX}"/usr/share/hwdata/usb.ids
		)
	fi

	meson_src_configure
}

src_install() {
	meson_src_install

	if use usbredir && use policykit; then
		# bug #775554 (and bug #851657)
		fowners root:root /usr/libexec/spice-client-glib-usb-acl-helper
		fperms 4755 /usr/libexec/spice-client-glib-usb-acl-helper
	fi

	make_desktop_entry spicy Spicy "utilities-terminal" "Network;RemoteAccess;"
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "Sound support (via pulseaudio)" media-plugins/gst-plugins-pulse
}