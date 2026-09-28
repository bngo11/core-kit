# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/5ad4e355c20fc63045d859a4fac8fbcf3bd444c6 -> skim-5.7.2-5ad4e35.tar.gz
https://direct.funtoo.org/de/f6/31/def63178ddb80d11db5ae7f1bfb5c114f2b3cebf70cc821cb2fbb677fb3747f7dc21492272684936c1d254c119018f3b20453671c9da8d0b42c2de18847ea928 -> skim-5.7.2-funtoo-crates-bundle-9c0f3f5a93846472cb43941f0cbde261221988f0b1c2a424a56c5f5348daf1887657adce3ad67a1f543ece0ca535b7affa79210f74ace7a2fa0ec8993dfa7cfc.tar.gz"

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