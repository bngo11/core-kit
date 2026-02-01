# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/2ac22b63448a2ca4917bee14e18aeb26253bf44b -> skim-2.0.0-2ac22b6.tar.gz
https://direct.funtoo.org/06/d2/e5/06d2e584c4f9b0f76f1168481e2a2c86936b06504531d938dff606e44c47c79526d0266dd2b599bad7a60f6d39fef1dfbe5b1aa5664c880f76b9a09a9623b8b3 -> skim-2.0.0-funtoo-crates-bundle-b743521b2701d8b0487b78c1bc6182c2ef6f589c39e0e38632b68dde7ad04342184e555df14f8ff598d7308835c3da80b184bc3ead7e0943ee810fe81acdcd52.tar.gz"

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