# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/f9e7760fdc0da0024d3e79dc096f26e38bdc3daf -> skim-3.4.0-f9e7760.tar.gz
https://direct.funtoo.org/bf/c6/fb/bfc6fb627f6ade51ddbee5146319158ef873eb6db41c11a869f5178e403ae37d124b489d2abe58e14f54a94c1340900e8dae714a75dbf48b8b526fd76d17a6e2 -> skim-3.4.0-funtoo-crates-bundle-5925ce2400a608228df9cb506a31475a24cd18c6c8357a5e29fd15e2f913512a9156fe1232f884588f9b700662c08c468a7b4ef840a1882b0c0dd10cb254566e.tar.gz"

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