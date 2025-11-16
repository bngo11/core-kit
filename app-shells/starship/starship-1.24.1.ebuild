# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://github.com/starship/starship/tarball/378f3e42be25c689164e720ba628c890a87c1f16 -> starship-1.24.1-378f3e4.tar.gz
https://direct.funtoo.org/bf/de/e2/bfdee2f75713d1b178bc709ac8d2969b39bd9757b465a3c6238d9fbb63f9c6fb5cb94cbb9705129e66471ec6eac85755471e70fa5f781074d9001e027e27c290 -> starship-1.24.1-funtoo-crates-bundle-8f789b52326dedc50e6803538b9a83529cb34a77e9d7551686d4609fd33b626a0bef57e7bbe0a5045b24998af0f944d26f4700097101e0279b65011e1e11fa04.tar.gz"
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