# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 go-module

DESCRIPTION="General-purpose command-line fuzzy finder, written in Golang"
HOMEPAGE="https://github.com/junegunn/fzf"

SRC_URI="https://github.com/junegunn/fzf/archive/0.42.0.tar.gz -> fzf-0.42.0.tar.gz
https://dev.gentoo.org/~sam/distfiles/app-shells/fzf/fzf-0.42.0-deps.tar.xz -> fzf-0.42.0-deps.tar.xz"

LICENSE="MIT BSD-with-disclosure"
SLOT="0"
KEYWORDS="*"

src_prepare() {
	default
	sed -i 's/-s -w //' Makefile || die # bug #795225
}

src_compile() {
	emake PREFIX="${EPREFIX}"/usr VERSION=${PV} REVISION=tarball bin/${PN}
}

src_install() {
	dobin bin/${PN}
	doman man/man1/${PN}.1

	dobin bin/${PN}-tmux
	doman man/man1/${PN}-tmux.1

	insinto /usr/share/vim/vimfiles/plugin
	doins plugin/${PN}.vim

	insinto /usr/share/nvim/runtime/plugin
	doins plugin/${PN}.vim

	newbashcomp shell/completion.bash ${PN}

	insinto /usr/share/zsh/site-functions
	newins shell/completion.zsh _${PN}

	insinto /usr/share/fzf
	doins shell/key-bindings.bash
	doins shell/key-bindings.fish
	doins shell/key-bindings.zsh
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "To add fzf support to your shell, make sure to use the right file"
		elog "from ${EROOT}/usr/share/fzf."
		elog
		elog "For bash, add the following line to ~/.bashrc:"
		elog
		elog "	# source ${EROOT}/usr/share/bash-completion/completions/fzf"
		elog "	# source ${EROOT}/usr/share/fzf/key-bindings.bash"
		elog
		elog "Plugins for Vim and Neovim are installed to respective directories"
		elog "and will work out of the box."
		elog
		elog "For fzf support in tmux see fzf-tmux(1)."
	fi
}