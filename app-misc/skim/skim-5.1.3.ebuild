# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/b41a724a2a1677d7ed5e3f7cca07dbbfdadefab3 -> skim-5.1.3-b41a724.tar.gz
https://direct.funtoo.org/b0/c6/70/b0c670115ab3ef0f6ceadd9f787dc8805a6942529c0a12d0f990e69d636a2679d15b125acadda2bafc74d6038b5b7701ec48c835402888c020e6bcafa3e62a1d -> skim-5.1.3-funtoo-crates-bundle-869dd8e20964c196f75fa7ed08677f3162598017d0be06025f4d434fbbe71bd419a39969f147232e9bcf82d30cf973fb199834d8b554fac9a0ce3b4b8e2ab688.tar.gz"

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