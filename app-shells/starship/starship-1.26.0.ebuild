# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://github.com/starship/starship/tarball/fca92d8dcbd5981b0160af2f7ed7a430b6475a72 -> starship-1.26.0-fca92d8.tar.gz
https://direct.funtoo.org/f7/2d/c1/f72dc1b68431c2bfe24468816107b09c82950c5b08789ba031d53e6b20da7cde1cf2d28b4d1f979b57f544018b55706f4c80fcb71ab81fa6410a9f40ca8e5d05 -> starship-1.26.0-funtoo-crates-bundle-6b974e932a110500d7a2fba8715a5d6a5e888d50a1ff007d14dbf97119cb6b84600fa355c188915e1db00f48f8d4b2b6b764dfcceee309b01d0b1d8547491bdb.tar.gz"
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