# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/7e462aa33e46f25058182ed936dba3616cb4d3e6 -> skim-3.5.0-7e462aa.tar.gz
https://direct.funtoo.org/e4/d6/73/e4d6736a82204e677bdd752afbdd053d6d049572cd84658a0eeaeb345662664af0c82909fea149d1d9962a34e97b750864734e86e9efa913084e952fa4557143 -> skim-3.5.0-funtoo-crates-bundle-8986497db19c958567a7ebdc0086b8795b7c41f63dcdcee8d10d1a70222f5a48d17cf3d4c5ec76eda6cc520db1eb4bc619ff75f62f60e2d781f3655878c61738.tar.gz"

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