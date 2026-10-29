# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/fe2bfbed9f85712e31d4fd5fedb6f15a81bb1a57 -> skim-5.9.0-fe2bfbe.tar.gz
https://direct.funtoo.org/2c/3d/c4/2c3dc42730a92f85f924b17fb75b1595033231be79420ed88f753830353d2aba8c10783817a13dabe84743932719b34fb199d62809eb94fe9a9700079f654bbc -> skim-5.9.0-funtoo-crates-bundle-413c603ebaa13ebe65eeeb3b768ed6d2e31bf49a1c3ebf3862127ceb272f9b88f1fa3b87403d24490ad077ba7735a950404b9c14e227c1a984e6df11aa495557.tar.gz"

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