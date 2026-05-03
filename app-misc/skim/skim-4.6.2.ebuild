# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/ec77fa7245228a572b4401efa5077d2a1e45d1d4 -> skim-4.6.2-ec77fa7.tar.gz
https://direct.funtoo.org/7f/c4/9c/7fc49c9d38dd4a5399586bf60626bad495758af96d61360bb0edd2271d18cec4d4f781270b44600220f85f001996cce65985c9bcdb4c74553ea6660aea994783 -> skim-4.6.2-funtoo-crates-bundle-062dc50a4d206691991d5077f728342ece5fa7e7534031dbf381d4c6d815edc83a27315d35a0183378afa2b780c745da721c25a0c7d9f22db0db7fe19a07075d.tar.gz"

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