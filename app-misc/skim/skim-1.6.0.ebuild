# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/d55c9b048736a2c9277fe78739bb5307f39069a1 -> skim-1.6.0-d55c9b0.tar.gz
https://direct.funtoo.org/96/0c/cd/960ccd5ad8ac8b6b977c41ab873e11ba0a6cdc6982bae97cc0cfc85e6588901a737ecaee620f8f1257d294bfa11794c28a6a486946f9fc1d2aa05702b975acdd -> skim-1.6.0-funtoo-crates-bundle-0c61f02b07bfe9ee928ffabfec9b2bbda828cbdb3a90a71b928589b7f80b1ee4aaac577378a6c33f588dc70a88d3e30deb101684a9297c0f4af9c575d9eb893e.tar.gz"

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