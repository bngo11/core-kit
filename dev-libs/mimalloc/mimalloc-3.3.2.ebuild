# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-multilib

DESCRIPTION="mimalloc is a compact general purpose allocator with excellent performance."
HOMEPAGE="https://github.com/microsoft/mimalloc"
SRC_URI="https://github.com/microsoft/mimalloc/tarball/30b2d9d89099bee08e9f67a1ffb3e12e7ba45227 -> mimalloc-3.3.2-30b2d9d.tar.gz"

LICENSE="MIT"
SLOT="0/2"
KEYWORDS="*"
IUSE="hardened test"
RESTRICT="!test? ( test )"

post_src_unpack() {
	if [ ! -d "${S}" ] ; then
		mv "${WORKDIR}"/microsoft-* "${S}" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DMI_SECURE=$(usex hardened)

		-DMI_INSTALL_TOPLEVEL=ON
		-DMI_BUILD_TESTS=$(usex test)

		-DMI_BUILD_OBJECT=OFF
		-DMI_BUILD_STATIC=OFF
	)

	cmake-multilib_src_configure
}