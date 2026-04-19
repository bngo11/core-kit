# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://github.com/starship/starship/tarball/457f16069b666d76e202708e0e3464122b57a6d5 -> starship-1.25.0-457f160.tar.gz
https://direct.funtoo.org/33/3c/07/333c072b2b505d51f28e044c78f39a6d1e6e38573d7d7a85a06ccac7cb0b17fc9553c6040046f0fc587a0ddeb2f72ddb9252474477ba29b5fe548defbe79a8f8 -> starship-1.25.0-funtoo-crates-bundle-035f849dc841558178e12907a63989387921440a275c82d68999209cb1421be5211e8ea84924f6a3d3a253497fefbd5cf991728d99cf04eb43095b1304d8c266.tar.gz"
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