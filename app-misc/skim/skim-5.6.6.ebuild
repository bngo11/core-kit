# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/4b962af9ede6f3fdda608bdce8031c352a4effb4 -> skim-5.6.6-4b962af.tar.gz
https://direct.funtoo.org/be/44/86/be44867a9c22611f398acfb6c4699aace7eed8f7fb1239ec4fe4c166c901cdd0caa9aaff427f503bef8c75530acbf7ea96c5e021c50cc149bb881e25d363db02 -> skim-5.6.6-funtoo-crates-bundle-58d4117e2b33b70491bc221a7b42605aa17938048a1ef949d3a669faf46adec94250955c0d455504cdc86a4df75a8b446509b2f1bca2892344c06c869fc85c93.tar.gz"

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