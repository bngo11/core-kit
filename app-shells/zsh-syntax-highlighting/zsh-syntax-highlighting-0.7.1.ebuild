# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit readme.gentoo-r1

DESCRIPTION="Fish shell like syntax highlighting for Zsh"
HOMEPAGE="https://github.com/zsh-users/zsh-syntax-highlighting/"
SRC_URI="https://api.github.com/repos/zsh-users/zsh-syntax-highlighting/tarball/refs/tags/0.7.1 -> zsh-syntax-highlighting-0.7.1.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

RDEPEND="app-shells/zsh"

DISABLE_AUTOFORMATTING=true
DOC_CONTENTS="\
To use syntax highlighting, enable it in the current interactive shell:
	. ${EROOT}/usr/share/zsh/plugins/${PN}/${PN}.zsh
For further information, please read the documentation files."

post_src_unpack() {
	mv ${WORKDIR}/zsh-users-zsh-syntax-highlighting-* ${S} || die
}

src_prepare() {
	default

	sed -i "s/COPYING.md//" Makefile || die
}

src_install() {
	readme.gentoo_create_doc

	emake DESTDIR="${ED}" PREFIX="/usr" \
		DOC_DIR="${ED}/usr/share/doc/${PF}" \
		install
	dodoc HACKING.md

	dosym "../../../${PN}/${PN}.zsh" \
		"/usr/share/zsh/plugins/${PN}/${PN}.zsh"
}

pkg_postinst() {
	readme.gentoo_print_elog
}