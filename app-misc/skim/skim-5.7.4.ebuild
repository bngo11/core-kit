# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/c147380a6a02bbdec757c7598494c1853e3d948c -> skim-5.7.4-c147380.tar.gz
https://direct.funtoo.org/c1/b6/77/c1b677642c272ecdcda2f5ebca44c756534be36e87822f44ab7ff96040379730566314ac9bc3471b5bf30632d45f1b355c8bcafbcca3dafd1924dfb8b4ce5013 -> skim-5.7.4-funtoo-crates-bundle-8ace7c736829e58a5406b33e2eeb8bc212a3849533d6ae0e7095db994a37004c9c29f9dee758db43af0924cba1b8ab56ce2e787f498eb3794d643d6dbd62b7e6.tar.gz"

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