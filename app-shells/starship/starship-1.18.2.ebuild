# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://github.com/starship/starship/tarball/4131edaa609887b866a5497648858fe6d39a3f99 -> starship-1.18.2-4131eda.tar.gz
https://direct.funtoo.org/cc/d9/f8/ccd9f8f11fbad7f6de990d6e486ba19037001eaec7fd8c6a45232c993a8f817db3c4201b3d5f07f52026630ed8d6fdb9ca731d1f3e2593ddeef669fd2a5e8282 -> starship-1.18.2-funtoo-crates-bundle-2dfeb6d5f8377ea9eec4e8a1b3a4e683a201c49f00f8556817f09f2a66daa1d6ddd1a7b2c503b7c0095070c840dc4c7be0555719a0865268c856f6358b58b382.tar.gz"
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