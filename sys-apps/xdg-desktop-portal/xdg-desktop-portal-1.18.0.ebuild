# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd meson

DESCRIPTION="Desktop integration portal"
HOMEPAGE="https://flatpak.org/ https://github.com/flatpak/xdg-desktop-portal"
SRC_URI="https://github.com/flatpak/xdg-desktop-portal/releases/download/1.18.0/xdg-desktop-portal-1.18.0.tar.xz -> xdg-desktop-portal-1.18.0.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="geolocation"

DEPEND="
	>=dev-libs/glib-2.66:2[dbus]
	dev-libs/json-glib
	>=sys-fs/fuse-3.10.0:3
	x11-libs/gdk-pixbuf
	geolocation? ( >=app-misc/geoclue-2.5.3:2.0 )
	>=media-video/pipewire-0.3:=
	>=sys-libs/libportal-0.6
	>=sys-apps/bubblewrap-0.6
	>=sys-apps/flatpak-1.14
"
RDEPEND="${DEPEND}
	sys-apps/dbus
"
BDEPEND="
	dev-util/gdbus-codegen
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Dsystemd-user-unit-dir="$(systemd_get_userunitdir)"
		$(meson_feature geolocation geoclue)
		-Dsystemd=disabled
	)

	meson_src_configure
}