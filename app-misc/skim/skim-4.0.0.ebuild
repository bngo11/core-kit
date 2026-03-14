# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/85c6964da5fb887a6c6bc71afb935a5aac671ad0 -> skim-4.0.0-85c6964.tar.gz
https://direct.funtoo.org/24/1e/05/241e057f5f531696522162fee52da94b9bc7bfc0fcceac077d65554bf6c428f749fa56735cef5210b96466c2acd23c24a3730dadd55bf28b28587a41e0533a92 -> skim-4.0.0-funtoo-crates-bundle-07879fa98774c1fe4e71d63006a1cf7bc7e6e977375538c22dc473193ea2a98553a0f7527a071288bb2a0a39cfbdaf71fd56ac224254ae65022df3552d0109b7.tar.gz"

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