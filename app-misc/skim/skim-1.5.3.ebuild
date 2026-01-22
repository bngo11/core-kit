# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/1c538e36b531c163b77925ffc657cd9f59b4ad3f -> skim-1.5.3-1c538e3.tar.gz
https://direct.funtoo.org/b9/28/3f/b9283f796800b20726aa2302e597149288ff183ff4e1c3694bd77e96ef12cb3cdf0c5f411dabb31c8350d4d5e049f01a8bf3dda7c3f7c1daac85b62f1e40c363 -> skim-1.5.3-funtoo-crates-bundle-33c673f2f4ccab581abdde061d49997ed39aa6d6a005a2ead4e698c70a5a47cd4ecde1e21940b8e76eadd55e75e2022887a212fe1ef8115301c8e9eefe6bbae4.tar.gz"

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