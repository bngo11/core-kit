# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/7e6115070b5c11e459af6b4ad0fe63cb6e5bbd90 -> skim-4.7.0-7e61150.tar.gz
https://direct.funtoo.org/9f/d7/f5/9fd7f55a63b01a9d0961f32ef0c286010b156f49a3cf74bc0b5151758e58d07d6dc27a3da0f9fd00e37ddc2e60bb8c70879063664f8a182d3102d958e52d9665 -> skim-4.7.0-funtoo-crates-bundle-3e3115a4207d0d09779e4ef9c00213460234bf2edc8eb90b12a3bce99ce0c9ee2400fd9087d4fe60b2c41837fb824ed40cc0d59d50a7bad0dc234d9d99d100f0.tar.gz"

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