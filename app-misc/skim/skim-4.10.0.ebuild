# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/aeba919fab2e33822596394a0df7e1461b4ba6da -> skim-4.10.0-aeba919.tar.gz
https://direct.funtoo.org/f9/95/cf/f995cf602f13a2d83b77a49bc44374976646b8971b0583fdff83c6cfc80040ad7c9af343d6555eeab27a11f74e2fe594815bb45b33f237282783a259fbbe01b9 -> skim-4.10.0-funtoo-crates-bundle-58aef294de4f51d71d1bf2710c3db129b28b4750e25e6d8b8f046576f2b872313dc8bf5e7f9fecd2b2f5589f3aa0a258ce396c3d329d9537f7d16b9d0acc596b.tar.gz"

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