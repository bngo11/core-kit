# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/e93e65c35205290f8e1d0ed833ac6c8016d7a818 -> skim-0.16.2-e93e65c.tar.gz
https://direct.funtoo.org/34/b6/e3/34b6e31d1822f983e70d556e4b012cd8ce04160d71a126028fc0d5863f937ff00e1478a7c296060641c0d215c605e55d7c7684e33fbeca60cf4c6d81d7aa66b7 -> skim-0.16.2-funtoo-crates-bundle-86260cac512dae6f8b5c61cd0451846abfc961f847f307b779450d3fb1ff1fa5922a6fcc370c0ed735c73222e3c4180546410ee394826330b75db669b208bb69.tar.gz"

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