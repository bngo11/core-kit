# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/fbd426f569dad01c83b0ea0f9690816c9485f7f2 -> skim-4.8.0-fbd426f.tar.gz
https://direct.funtoo.org/3d/87/2c/3d872cebb01587193cb354642c3b950d70c030ad66d32278994a8925596fb7f08359ea2ba8ef1cb153218d445e9da868f503e8ba3ae19e974041691d1f67bf06 -> skim-4.8.0-funtoo-crates-bundle-b0105b185a6c56aff5174cbc1a5b4ff59319c1557dabd0d4fe5be4a2e370308cf76f17298f254af6e6ef58b7e60be3f70779e0c1a02ef9ccfaf6851cc45a16da.tar.gz"

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