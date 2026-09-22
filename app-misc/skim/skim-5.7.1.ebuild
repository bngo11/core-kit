# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/6de676121673cf8d0c739596763dd5b3d2075d98 -> skim-5.7.1-6de6761.tar.gz
https://direct.funtoo.org/3f/91/ca/3f91cac75be3b735a8dae62e85133d051f6db8a62fc4bb0d48cbb50be76ad893cccb0a084d8e98e985ef5154d2fc79deb12e0307379b0c9cea49393caafc8fa6 -> skim-5.7.1-funtoo-crates-bundle-c27993557e0a766f86bb2bbc8ba669da4d80d8e02c9dc4345104c8eef0030f71159e01a1ef28ce0e9fb4795b86b953f1e7a03ce2190408b3946b5d3f67680090.tar.gz"

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