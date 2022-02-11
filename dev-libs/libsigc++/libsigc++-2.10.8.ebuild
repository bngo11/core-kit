# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit gnome3 flag-o-matic meson

DESCRIPTION="Typesafe callback system for standard C++"
HOMEPAGE="http://libsigc.sourceforge.net/"

LICENSE="LGPL-2.1+"
SLOT="2"
KEYWORDS="*"
IUSE="doc static-libs test"

RDEPEND=""
DEPEND="sys-devel/m4
	doc? ( app-doc/doxygen )
	test? ( dev-libs/boost )"
# Needs mm-common for eautoreconf

src_configure() {
	filter-flags -fno-exceptions #84263

	local emesonargs=(
		-Dbuild-examples=false
		$(meson_use doc build-documentation)
		$(meson_use test benchmark)
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	einstalldocs

	# Note: html docs are installed into /usr/share/doc/libsigc++-2.0
	# We can't use /usr/share/doc/${PF} because of links from glibmm etc. docs
	use doc && dodoc -r examples
}