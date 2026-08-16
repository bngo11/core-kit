# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/1b80cff3f72198da1ea334eef880a30327d37926 -> skim-5.6.5-1b80cff.tar.gz
https://direct.funtoo.org/01/7a/96/017a9623dd0e6ef7f4fda210a1f655004d7e32f1d212555630ff0102e7f02621f42b66e554d8869a1edcfd88b53d8ce3f4e8979fa0b5e900202e937fa313b746 -> skim-5.6.5-funtoo-crates-bundle-7589ff0e5e627a9ca53277f57e730d0c6e5adad2bec2a6ac6b127392ed48b37ab0282b4d3b57a0cd9d624ea5ebfcdc03d17d69229689413c27b6a2ffe2fce3db.tar.gz"

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