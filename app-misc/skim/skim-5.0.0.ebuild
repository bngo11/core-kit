# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/5a2dde80187e73c9391356b13716e13b9009c779 -> skim-5.0.0-5a2dde8.tar.gz
https://direct.funtoo.org/33/48/cd/3348cd28d69a3e71aeea64344f12c16e6632e67ac57d1eb403372d8819bc3e63b19bb88549a0df608dbca8d20a64db256f6c45b5a6c51b75eaea64e8c2cce761 -> skim-5.0.0-funtoo-crates-bundle-47b40ad0046f79a0595a64e4a50f5a3c36bf9a09b5851ceb92f7cfe45ae79db81bd07c4692190365b1da56b3b13e6b82aab3ac26909eb915e835016b889d05c0.tar.gz"

LICENSE="Apache-2.0 MIT MPL-2.0 Unlicense"
SLOT="0"
KEYWORDS="*"
IUSE="tmux vim"

RDEPEND="
	tmux? ( app-misc/tmux )
	vim? ( || ( app-editors/vim app-editors/gvim ) )
"
BDEPEND="virtual/rust"

QA_FLAGS_IGNORED="usr/bin/sk"

src_unpack() {
	cargo_src_unpack
	rm -rf ${S}
	mv ${WORKDIR}/lotabout-skim-* ${S} || die
}

src_install() {
	# prevent cargo_src_install() blowing up on man installation
	mv man manpages || die

	cargo_src_install
	dodoc CHANGELOG.md README.md
	doman manpages/man1/*

	use tmux && dobin bin/sk-tmux

	if use vim; then
		insinto /usr/share/vim/vimfiles/plugin
		doins plugin/skim.vim
	fi

	# install bash/zsh completion and keybindings
	# since provided completions override a lot of commands, install to /usr/share
	insinto /usr/share/${PN}
	doins shell/{*.bash,*.zsh}
}