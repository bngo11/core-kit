# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/8d92d05b8e9ef1c6dfc5c190151aa9377907cc56 -> skim-4.6.1-8d92d05.tar.gz
https://direct.funtoo.org/6b/69/b0/6b69b013074d2cd591e041cd37abb1ddd1d6ecc6920cf59eeab9082ac564bbfec938fd529b7842e5666c6f51005fc4e6d8cf74020ba62c92634de5c6a1cc11b0 -> skim-4.6.1-funtoo-crates-bundle-38fa9ffb34333cc588ccee376fbac7f2a5261b37df6870d668eede36efc565f093e25940a529697aad192bc167ad8aa3184ff84615ac475511137db32660dbbb.tar.gz"

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