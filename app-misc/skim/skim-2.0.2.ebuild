# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/e93c152d8db6a5ef79151a0d8ccfcd6c540bf290 -> skim-2.0.2-e93c152.tar.gz
https://direct.funtoo.org/be/75/ea/be75eaced918abe63f53669f771005611110e6d0f44e9548479ab75aa0f1f57842dcb3e72903063624cb7bedd022a8d4793159d980965c2321b037e7619e4837 -> skim-2.0.2-funtoo-crates-bundle-54c80a7d340f3d25396c4ea7c637029348bb98a4388819515f8a58a909ca62964c0c42c1d5eafdcb3b61d83f6dece246d486f5c5f65ca0e0ea7669b69b935e15.tar.gz"

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