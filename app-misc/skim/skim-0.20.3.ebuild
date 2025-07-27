# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/bc3c4a0ad38ad94db891f4d0cbf01ecda5ed650e -> skim-0.20.3-bc3c4a0.tar.gz
https://direct.funtoo.org/5d/c6/cd/5dc6cd4746d4e59fb74da51dc7ad8094c65d9dc852444db0f60c827eb1dae9d8e5074c7ab470365a32eefab878b3ecff285e06ead87becfc4e6984ab685eff49 -> skim-0.20.3-funtoo-crates-bundle-6d164d47907971550ffe492ff4d6279a6c7b336920dfff3bbd060820407d10fd919b2f1116b0c8794fd842062631e62e6c2edcbc6e7278bdb823c85a4f51f2a8.tar.gz"

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