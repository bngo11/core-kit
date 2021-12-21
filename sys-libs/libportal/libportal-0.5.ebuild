# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="Flatpak portal library"
HOMEPAGE="https://github.com/flatpak/libportal"
SRC_URI="https://github.com/flatpak/libportal/releases/download/0.5/libportal-0.5.tar.xz -> libportal-0.5.tar.xz"

LICENSE="LGPL-2"
SLOT="0"
IUSE=""

KEYWORDS="*"

RDEPEND="dev-libs/glib:2"

DEPEND="${RDEPEND}
	dev-util/gtk-doc"

src_configure() {

	local emesonargs=(
		-Dbuild-portal-test=false
	)

	meson_src_configure

}