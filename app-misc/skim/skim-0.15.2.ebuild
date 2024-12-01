# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/dd41167d423bfaeb06a9695b60df72a07b8c8afd -> skim-0.15.2-dd41167.tar.gz
https://direct.funtoo.org/99/23/47/992347de53de0cf68c862cd6c18b8a826e070981e1f998680d7519e93e887bf9a0cd43cdfb965e2312d53434d66c00da445b23c4e52a8e50b1fa4241b7d13aa0 -> skim-0.15.2-funtoo-crates-bundle-ddbfbd2c058b4c5d1bebcbf53ad1914373a7d7b7a05bd0307a3c34bb3b775477bdf06a9f1ab02429e248f92525de6868060105752c6285943248c6bf8b6fc49e.tar.gz"

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