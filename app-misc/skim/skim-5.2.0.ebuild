# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/57a7487323b7f63f28a0e142ba38136b79dca11b -> skim-5.2.0-57a7487.tar.gz
https://direct.funtoo.org/9b/19/fe/9b19fe4d822349324067d2331a677d228d26b0a792194f4a5ce4aadc6b0f77723944034ef7ca1227ebfdef4ddd88004cf9cd81bc518908028a4abb4ce6665d84 -> skim-5.2.0-funtoo-crates-bundle-3962a4148b0eee4aacefc8a9d7cb962d99ffd59afb4d4dfec63e353cc3a28d5738efbfb389855b4d50d2e314b192b347f53f50f375a02f4865006bc964cbb2d2.tar.gz"

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