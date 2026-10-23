# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/2e638bf5a693860d1d226a96c1b220aaa9ea227f -> skim-5.8.0-2e638bf.tar.gz
https://direct.funtoo.org/62/d5/2f/62d52f6650f3d31e1c500a357b02c40ef34d0a3922a747278d7a803f2d7e57f15cb249e0a8e04cfe297d125165102a6472ef1165b2f09ac2c089888899752af1 -> skim-5.8.0-funtoo-crates-bundle-5479b35503993065ce758d024aed99984560f126965000bdbef04a72fa7e03f14728587165c185aa6fb023a14c7d044127e3ab2d1ebaa39016f7839ccd1d3098.tar.gz"

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