# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fly through your shell history. Great Scott!"
HOMEPAGE="https://github.com/cantino/mcfly"
SRC_URI="https://github.com/cantino/mcfly/tarball/0dc3017781a5db096bf2aed801af28858378272d -> mcfly-0.9.0-0dc3017.tar.gz
https://direct.funtoo.org/d8/72/00/d87200b7ec07c2a918cbcac0db8e27e213661837c0b92b77dd2a32e773621d7837cdde6d432eb26730ce26fa7121479f95989de8dbbd1c3defed20f15adf5617 -> mcfly-0.9.0-funtoo-crates-bundle-cff06f3ddbb680d2f52cd188dbcf1b3e342b859108cb454fff3cf8a3e51d07b492601fcc2084501bc2e9ae47f0404f207983775214c38b57824786ed0442b6a9.tar.gz"

LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 MIT Unlicense"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-db/sqlite:3"
RDEPEND="${DEPEND}"
BDEPEND="virtual/rust"

QA_FLAGS_IGNORED="/usr/bin/mcfly"

src_unpack() {
	cargo_src_unpack
	rm -rf ${S}
	mv ${WORKDIR}/cantino-mcfly-* ${S} || die
}

src_install() {
	cargo_src_install

	insinto "/usr/share/${PN}"
	doins "${PN}".{bash,fish,zsh}

	einstalldocs
}

pkg_postinst() {

	elog "To start using ${PN}, add the following to your shell:"
	elog
	elog "~/.bashrc"
	local p="${EPREFIX}/usr/share/${PN}/${PN}.bash"
	elog "[[ -f ${p} ]] && source ${p}"
	elog
	elog "~/.config/fish/config.fish"
	local p="${EPREFIX}/usr/share/${PN}/${PN}.fish"
	elog "if test -r ${p}"
	elog "    source ${p}"
	elog "    mcfly_key_bindings"
	elog
	elog "~/.zsh"
	local p="${EPREFIX}/usr/share/${PN}/${PN}.zsh"
	elog "[[ -f ${p} ]] && source ${p}"
}