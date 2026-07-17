# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/f87ce2075dcac9211ccb9f6654f70e6ca5064a39 -> skim-5.1.4-f87ce20.tar.gz
https://direct.funtoo.org/37/8f/be/378fbe252135cb2fd1a1305ae6ae845216a3e508be1d4da396317be68e58f5f51df894defc2eb816c893db9f549e9873ef1169ba2354612fa36e92826ddff8d2 -> skim-5.1.4-funtoo-crates-bundle-49ae7a6c210be352b1a2f06c751530378c7903a822b8257fd8518a2491a22da2bdc4c9819c11385ca0ed2e0d127f0355425881af83e0f0bee6531e48ee950f85.tar.gz"

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