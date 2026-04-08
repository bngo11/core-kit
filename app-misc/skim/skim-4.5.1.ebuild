# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/ada7cc6264110fe76510213fdd95b1eafc843544 -> skim-4.5.1-ada7cc6.tar.gz
https://direct.funtoo.org/dd/9f/ab/dd9fab71f74f8476700c96a4183a8bc40502bcb4622d6e63f4205a05183df9d631a7ad38c58740b24d7a40b916e11b80958b0fae46b92b91e22c83a140fddd5f -> skim-4.5.1-funtoo-crates-bundle-3d1ed2127c7bb6f0a63d9a63786bb3e290fead9bb5ee0f61979d457798682d13c947afe9c92920a70e7604913af7eade41fd8fee41df008ae9a346e2683d1356.tar.gz"

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