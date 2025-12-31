# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://github.com/starship/starship/tarball/33f7077fbe9d7f30476c96645e482be323d42566 -> starship-1.24.2-33f7077.tar.gz
https://direct.funtoo.org/c4/cc/90/c4cc9039b9aac55e641a3a795fcbc1ada4cc0c691fff404cd1cf7d7e204a3e38f81a46ff134f6327e489cb48b0036b824859eaceab10fafcb9aef34b86824f54 -> starship-1.24.2-funtoo-crates-bundle-f89ba84c35728cdecb310f6ccfb2b9a763d7c0e1e0b71e2ebd7271e8156c697c3b5dae68502460828aab3415a464fcf7d0e0abd39154c101d0b193ee7f3bf35e.tar.gz"
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