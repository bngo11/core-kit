# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/19bfd34aaf8ce9f4c2852530d3f6f19d4f714654 -> skim-3.2.0-19bfd34.tar.gz
https://direct.funtoo.org/cc/74/3e/cc743e966324a1cc5ff3bea72a65fd9822faa4dd5b437524273709cc43674a2e1fa56ab1a8aa783a509d05f85d63f5fe21ca513fcc164dae8564747aa5901b14 -> skim-3.2.0-funtoo-crates-bundle-dbf7e9a86a9cb94073d77d131e88d6a49ff45698c25fc4ed81a1b6fb00b2cca600c886dc595bf224cad03cb0e6898b7d7879502126a2d4aec14683935dbeb166.tar.gz"

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