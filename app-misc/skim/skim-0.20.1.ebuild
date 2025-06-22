# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/34ef044ef450c90fadf3099165dd3a1c45841ec2 -> skim-0.20.1-34ef044.tar.gz
https://direct.funtoo.org/90/01/76/900176bc6eaaa1d7f70b0b2093dbf091517c7af122139d978ff04c1cfde68711567d443afbf10a85dd001098e7e7bd5efa704cb6a9aa434a96746c2cdb36debb -> skim-0.20.1-funtoo-crates-bundle-f4c5ddaf875b4c07ee593e59c5d7850137dc4f9138cb8466ef82ad17adcd1b90ab22c43d4cf938c6f13c5fac82b3a81a379ef7134f706d84b81e899be8ef0ee2.tar.gz"

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