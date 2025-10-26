# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://github.com/starship/starship/tarball/083870239e31bb4ca37d6a5877b8c018c1d41279 -> starship-1.24.0-0838702.tar.gz
https://direct.funtoo.org/69/12/f1/6912f1b54cd261f27e5de1189315e571fd53244d4dfac082edb22ea4ec1ffe312253faec0ec7ccc45151602b5cc3cb0c29b1602591989f5c7cc92ed3b0ac52ba -> starship-1.24.0-funtoo-crates-bundle-48f7bb0e835b0e1d4a7f8f54051b1399f1d580711f1f9350d3a290c90ee6cc6d54506eee8793a1a854a560fe61a83c0336f522fe6d956e372de055a24fd04138.tar.gz"
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