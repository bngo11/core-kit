# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/d8eda628fe90c8dba7e4fcb64cbb0bad9d05f7fd -> skim-1.3.0-d8eda62.tar.gz
https://direct.funtoo.org/80/b5/db/80b5db789d080ea90c9fa477963a3d4fa983946f1070570ec7fa84fe90341e62eb179eba5aed7948210f375c6b3f58043fa874b512e957edb4a2f8d4017838f9 -> skim-1.3.0-funtoo-crates-bundle-3fe670486da8ee1d594b526205fad5d3992b7fab0e1d941c760f925c54bc946e19ccf6bbd47c50bfcfb0d496ee2d4e2c29e728ccced3c6390efc492716695168.tar.gz"

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