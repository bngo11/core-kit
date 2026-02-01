# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/1c1279514bc0fbe55244d6e9160d945374ed3559 -> skim-2.0.1-1c12795.tar.gz
https://direct.funtoo.org/90/0a/3c/900a3c0ba8c05b41267692ef76158f2fb21fe9e711ec37be9833ee7f0ef308f52585396ab1b697869376aa28db10020725d5a9a0f709c07b220811b2dbadd675 -> skim-2.0.1-funtoo-crates-bundle-5629bddd4737ecd8f5be886a5011ba124a92218816154e2e5673f7960f3cc30e0c21dcbead2901c0f415209b72c66b2f20ddbff1049dc1e1ecbfff7adf26698c.tar.gz"

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