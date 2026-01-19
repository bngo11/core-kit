# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/484eb6a75e9f98fd3ce30ba6e8edb963fa8c5a99 -> skim-1.0.1-484eb6a.tar.gz
https://direct.funtoo.org/b6/17/cd/b617cdfff6b5c000a5be3263f2a88307b7cd6ea2e2e7bff53374e84b81815ed6671f002a11743463027d2fcd892eb8c0a85e254840aa9e4179ed0215bc13bb8d -> skim-1.0.1-funtoo-crates-bundle-88d00d9c391ee937c984fc2ec20bf7eb5425c71f5527e5dc2b2f909c8bb282ad383d714bf81ed8cfbaf7f82f08e00bcaaf58ab70aac93d8e8fdb8b0a012cf832.tar.gz"

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