# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/9016a712a28be2d86d07fe71a7dd9ed153e9b353 -> skim-5.5.0-9016a71.tar.gz
https://direct.funtoo.org/8b/b1/a7/8bb1a7be931a1973039f174dbc2a7bdcf38e3b8ce4da8aa89531da22ec58ee48ac56aa6ef0782372a4c5ab29b7f5db7251d699cc207b6177ebc3bab257caa0b5 -> skim-5.5.0-funtoo-crates-bundle-5dc89af0d8aa14c20a3387f2a1b2bb5a009e344b22f472bab007f54d0453afbe216d8b131c0718e42c435f6b543bd3e8fbf80e708a1f1cb6f5a152c9b0c65a69.tar.gz"

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