# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 toolchain-funcs xdg-utils

DESCRIPTION="The missing terminal file browser for X"
HOMEPAGE="https://github.com/jarun/nnn"
SRC_URI="https://api.github.com/repos/jarun/nnn/tarball/v4.4 -> nnn-4.4.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="+bash-completion fish-completion zsh-completion"

DEPEND="
	sys-libs/ncurses:0=
	sys-libs/readline:0=
"
RDEPEND="${DEPEND}"

post_src_unpack() {
	mv "${WORKDIR}"/jarun-nnn-* "${S}" || die
}

src_prepare() {
	default

	tc-export CC
	sed -i -e '/install: all/install:/' Makefile || die "sed failed"
}

src_install() {
	emake PREFIX="${EPREFIX}/usr" DESTDIR="${D}" install
	emake PREFIX="${EPREFIX}/usr" DESTDIR="${D}" install-desktop

	if use bash-completion; then
		newbashcomp misc/auto-completion/bash/nnn-completion.bash nnn
	fi

	if use fish-completion; then
		insinto /usr/share/fish/vendor_completions.d
		doins misc/auto-completion/fish/nnn.fish
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins misc/auto-completion/zsh/_nnn
	fi

	einstalldocs
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}