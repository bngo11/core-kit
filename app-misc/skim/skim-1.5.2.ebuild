# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/432a692e68d24f59a0addf00ec46238eee55f020 -> skim-1.5.2-432a692.tar.gz
https://direct.funtoo.org/4d/9b/47/4d9b471114dfe2b3ddb742a6a07ad7a20683b18d83cba7c931d7eac4b45bce6971905fd40f602f88705070e9c3b4a6db99d4265f0a169f615fe0ac256b74a734 -> skim-1.5.2-funtoo-crates-bundle-33c673f2f4ccab581abdde061d49997ed39aa6d6a005a2ead4e698c70a5a47cd4ecde1e21940b8e76eadd55e75e2022887a212fe1ef8115301c8e9eefe6bbae4.tar.gz"

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