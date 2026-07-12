# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/c4bc5e1be48367a7fec8a90b0e2550635eed7f3d -> skim-5.1.0-c4bc5e1.tar.gz
https://direct.funtoo.org/ff/dd/51/ffdd51ce8674d0c9d2227130d1c69d83ad9764b0cab9b3390699741a933564cf789183a747be2ad50167dc38c89b8aeb9bee8abc2df25a56234a52327c319dd5 -> skim-5.1.0-funtoo-crates-bundle-9f1b5d8210c384ff438b5c20d18a5743ee7e89faa14c0229213fa2292c21f4d36eb087ae0f290f0c3183d9867521791db0e887d1e74a7df857276cf6427f3ca3.tar.gz"

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