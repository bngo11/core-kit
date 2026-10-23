# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-multilib

DESCRIPTION="mimalloc is a compact general purpose allocator with excellent performance."
HOMEPAGE="https://github.com/microsoft/mimalloc"
SRC_URI="https://github.com/microsoft/mimalloc/tarball/b18ab4eef383f655e760881b02eff8af02800879 -> mimalloc-3.6.0-b18ab4e.tar.gz"

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