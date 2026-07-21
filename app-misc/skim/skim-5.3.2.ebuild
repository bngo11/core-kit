# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/5c1c3379fb9ee5124884b0934198f9487d24d02d -> skim-5.3.2-5c1c337.tar.gz
https://direct.funtoo.org/8c/7b/24/8c7b2432e1680b4163a2069bd5b93e303a7e3311eddc7bc87046aba0f26d7510c6fb4437e841efbe6be93b61b0af8556fb503a06a278c303bf71a7a93c2a7e00 -> skim-5.3.2-funtoo-crates-bundle-fd6da95bc5837dacc8e56b8f30e76233023c982e193a2791a1dcd49c6e661585a98d200da545a4dc50bb0fa754e39441cb5a95cc3ca73043e863b9dc93c1798a.tar.gz"

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