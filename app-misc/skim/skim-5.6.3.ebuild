# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/5fc3b0c1a0cb1f42cfe9b9edab13b719d74e1bbd -> skim-5.6.3-5fc3b0c.tar.gz
https://direct.funtoo.org/cb/ac/4e/cbac4e7041e19fd3085b8f51f09bb132a33278386c0a47c1dd0ebd55b55b445e9f278eb9245afc23ef721e18e52fc7d3e21ddd3ddaca5ec887ca68dbc89db1b2 -> skim-5.6.3-funtoo-crates-bundle-242ab414cf6fbb352fd9fd5fdb5a52ab776a3f27d1ba8157d6f8da0307be313086c68ca782fa74a4c22789270815a1f6ef358e68d75c87d9af7a1ae516efb1da.tar.gz"

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