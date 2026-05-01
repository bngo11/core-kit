# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://github.com/starship/starship/tarball/8758daa7767d4e73874330b1e262fca66a7ffd30 -> starship-1.25.1-8758daa.tar.gz
https://direct.funtoo.org/b3/e3/e6/b3e3e6fb917ddbe6e573d67c500435044545913419cdef01ffb60f5e0022ec7b674ac47435d4e5ef0eb98891900a8fa020db0efd7d6e0ebf161ea910c1b968be -> starship-1.25.1-funtoo-crates-bundle-1b96e5b66a0c480a8353e07e2f57d2287048789b110b989fa482c4feaea5fdc283ec53d8a68f5b31bf50df0a6f4642ccedb758d437f0c86a07c5f1d8377c02ee.tar.gz"
LICENSE="ISC"
SLOT="0"
KEYWORDS="*"
IUSE="libressl"

DEPEND="
	libressl? ( dev-libs/libressl:0= )
	!libressl? ( dev-libs/openssl:0= )
	sys-libs/zlib:=
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/rust"

DOCS="docs/README.md"

src_unpack() {
	cargo_src_unpack
	rm -rf ${S}
	mv ${WORKDIR}/starship-starship-* ${S} || die
}

src_install() {
	dobin target/release/${PN}
	default
}

pkg_postinst() {
	echo
	elog "Thanks for installing starship."
	elog "For better experience, it's suggested to install some Powerline font."
	elog "You can get some from https://github.com/powerline/fonts"
	echo
}