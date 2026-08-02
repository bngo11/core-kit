# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/c398374a85967c83cad0646807d99cac62de5d6c -> skim-5.6.1-c398374.tar.gz
https://direct.funtoo.org/64/95/0e/64950e437b8e8d56c87b2b5ef3f198482e4c3fe9fc4aba1162175afb622b0717c17e61cfb04fc6ba6a1b222bc9fc183fb5c6378cfda71b3a05565f6199075d1a -> skim-5.6.1-funtoo-crates-bundle-b6d7e9a2477dddd5818a73b1a51f4aa613f0834322f75e0e64ba3173b5759cbbee7eb71471bbb9ffbb86c2baf24e1935ed2fc7ccd37f3a2757e05d95f6e52421.tar.gz"

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