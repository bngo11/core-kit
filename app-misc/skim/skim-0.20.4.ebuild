# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/a59637f117eca56b215fc71a833f113c8395bbdf -> skim-0.20.4-a59637f.tar.gz
https://direct.funtoo.org/03/7c/95/037c95d27c8f44f5b16f81936725a376a6933a472e60e9c29578f8c218772144b45de5c7fd690eb998ef851844769dbd59e7f5a275f2222f5537c9add41661e0 -> skim-0.20.4-funtoo-crates-bundle-9a81d212129c2cce043516f77526e3c4857b9c40cc48063ca0df8d87ee2134c221a29ee42fc9c7f7ab9707f5e6be531be0f4e0d0b045ec93ae172ed8e1a814d8.tar.gz"

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