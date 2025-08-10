# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/6ddba45d225e113556a2d8f9ab84ab3d1c5f41de -> skim-0.20.5-6ddba45.tar.gz
https://direct.funtoo.org/da/aa/46/daaa463df290010292cc7a79d31697ce826bffdb5fb2af66104ea03f644c0db0188452731947305bafe8278277fa972bfa6bab631a47740f550171a018cb8e36 -> skim-0.20.5-funtoo-crates-bundle-ccee91d59948692c6b8cc4c6b14ffaf078d7a1a055a583935c6e2847368766beadf40b8603126cfa6ab7eeecda6e97ae8f7d5af54517fc2e9e81e7e55006bc14.tar.gz"

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