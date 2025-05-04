# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/35bf6964c454c406a75ddf96d2235574a4553c2d -> skim-0.17.1-35bf696.tar.gz
https://direct.funtoo.org/fa/63/f1/fa63f10519de4612e1e7f0ddfcc037c9aae346685116c8610af4bad324672ea92d41b79fc3ceaea73960a7df1d468715926e4d1b72ff3411a6d27621aa33bb3a -> skim-0.17.1-funtoo-crates-bundle-de8a8cd8a1bcc39f78b1f95a29c48fd473ad37d5199d14fabdbdb4419746f5733131f4c1d41e3bdfe2aea6be470229bfebed8a81a0669534b1291ffb84efb487.tar.gz"

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