# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson vala

DESCRIPTION="Flatpak portal library"
HOMEPAGE="https://github.com/flatpak/libportal"
SRC_URI="https://github.com/flatpak/libportal/releases/download/0.6/libportal-0.6.tar.xz -> libportal-0.6.tar.xz"

LICENSE="LGPL-2"
SLOT="0"
IUSE="gtk4 qt5"

KEYWORDS="*"

RDEPEND="
	dev-libs/glib:2
	gtk4? ( >=x11-libs/gtk-4.0 )
	qt5? ( >=dev-qt/qtcore-5.15 )
"

DEPEND="${RDEPEND}
	dev-util/gtk-doc"

src_prepare() {

	default
	vala_src_prepare

}

src_configure() {
	local backends="gtk3"

	if use gtk4; then
		backends+=",gtk4"
	fi

	if use qt5; then
		backends+=",qt5"
	fi

	local emesonargs=(
		-Dbackends=$backends
		-Dportal-tests=false
	)

	meson_src_configure

}