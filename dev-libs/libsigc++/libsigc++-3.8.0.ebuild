# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome3 flag-o-matic meson

DESCRIPTION="Typesafe callback system for standard C++"
HOMEPAGE="http://libsigc.sourceforge.net/"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="*"

IUSE="doc static-libs test"

RDEPEND=""
DEPEND="sys-devel/m4
	doc? ( app-doc/doxygen )
	test? ( dev-libs/boost:= )"

src_prepare() {
	gnome3_src_prepare
}

src_configure() {
	filter-flags -fno-exceptions #84263

	local emesonargs=(
		$(meson_use doc build-documentation)
		$(meson_use test benchmark)
	)

	meson_src_configure
}

src_install() {
	gnome3_src_install
	meson_src_install

	einstalldocs
}