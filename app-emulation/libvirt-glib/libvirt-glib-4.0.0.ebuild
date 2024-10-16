# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME3_LA_PUNT="yes"

inherit gnome3 meson vala

DESCRIPTION="GLib and GObject mappings for libvirt"
HOMEPAGE="http://libvirt.org"
SRC_URI="https://libvirt.org/sources/glib/libvirt-glib-4.0.0.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="+introspection +vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	dev-libs/libxml2:2
	>=app-emulation/libvirt-1.2.6:=
	>=dev-libs/glib-2.38.0:2
	introspection? ( >=dev-libs/gobject-introspection-1.36.0:= )"
DEPEND="${RDEPEND}
	dev-util/glib-utils
	dev-util/gtk-doc-am
	>=dev-util/intltool-0.35.0
	virtual/pkgconfig
	vala? ( $(vala_depend) )"

src_prepare() {
	use vala && vala_src_prepare
	default
}

src_configure() {
	local emesonargs=(
		$(meson_feature introspection)
		$(meson_feature vala vapi)
	)

	meson_src_configure
}