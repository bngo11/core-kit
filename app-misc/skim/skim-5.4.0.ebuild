# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/b2a732efa05d9a7656626ba589df75e7db09d95b -> skim-5.4.0-b2a732e.tar.gz
https://direct.funtoo.org/d7/e9/a4/d7e9a42c237f53f7e65c9fd07b8fcabb4c9edd25302da044afaa42c789dd1f238cbb5cd065434475a02412fe877b5a6eadf39757c55f5d2859b6673e08c1666c -> skim-5.4.0-funtoo-crates-bundle-1dc9389879204ee37bf3f0e50b854f47a923658682c5f81637422d0470b3b2f2f119be698564355711e4bc7a42f0edcc92b1f3cec42e38bcfd5654badec971ee.tar.gz"

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