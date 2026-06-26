# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/d14407196b3887096b7daa66fe31d0a3f2704b8c -> skim-4.9.0-d144071.tar.gz
https://direct.funtoo.org/ba/44/5f/ba445f28eff43eae24ba8d08a4014eafec5267349405efad8e8da283e388c5d4a45394cf20b32c6641e0ad530201e4b6547a2fb061f5422947460404c6cebae0 -> skim-4.9.0-funtoo-crates-bundle-06179b90669ba09e08e3d10e25561bed7e22c9c462c381bc051a6f1ff49b62477f1506fe36f8a5b3fc399307d23dcaa9d9bec1f32a17bf6b141a32cfb853d11f.tar.gz"

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