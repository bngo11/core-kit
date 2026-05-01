# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://github.com/starship/starship/tarball/8758daa7767d4e73874330b1e262fca66a7ffd30 -> starship-1.25.1-8758daa.tar.gz
https://direct.funtoo.org/4a/53/cc/4a53cc063f5078cd9051968a98d20dbf145adf2a1cd64c7b5a8f0c8a42481407ac734d70b3f315a0600e5436fbe1e929167f6bc503ef604e56a7b0a415df5eec -> starship-1.25.1-funtoo-crates-bundle-1b96e5b66a0c480a8353e07e2f57d2287048789b110b989fa482c4feaea5fdc283ec53d8a68f5b31bf50df0a6f4642ccedb758d437f0c86a07c5f1d8377c02ee.tar.gz"
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