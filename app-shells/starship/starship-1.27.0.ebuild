# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="The minimal, blazing-fast, and infinitely customizable prompt for any shell"
HOMEPAGE="https://github.com/starship/starship"
SRC_URI="https://github.com/starship/starship/tarball/f8e4e2155542cc84f49b342122d371f74e0ad253 -> starship-1.27.0-f8e4e21.tar.gz
https://direct.funtoo.org/bb/b9/3a/bbb93acd35c517d521356e7ea8f869ac8d972da69575ef43a3c700ed6e48bf365137f9bdda1f3af74fd0cfad7e3234fe0cb92564daa17c036bcc5b878c3e77ef -> starship-1.27.0-funtoo-crates-bundle-b52a6de1a5f27cb021e9cc0842e18f82de9140acef6b6fc25a710cd82f97eeb9a6bef49216e392d60dc3b45d33a57970deafc59375028f4850907767e137c56f.tar.gz"
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