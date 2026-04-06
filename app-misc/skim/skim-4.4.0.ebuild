# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/a18e88aafd3686a61f95640604016897dc2632f5 -> skim-4.4.0-a18e88a.tar.gz
https://direct.funtoo.org/5e/15/6f/5e156fbde5c1bab9d17adc9df6632e0671df051a08a4fd0844ce927a48ddc63b626dad753a0526c17d8de3ce3966c0eb7a8ebb533f5e30c4d63969e0c3ff0ec6 -> skim-4.4.0-funtoo-crates-bundle-1eb1c92839c9183400953077c7fc0c1701e34d9a634a1576a0cb0b785f8fefd9ee9694b6437f18b626c6a94e992b30c988767e3625f6d737ade7e35aaf6422d0.tar.gz"

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