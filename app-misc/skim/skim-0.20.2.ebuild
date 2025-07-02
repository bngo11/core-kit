# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/7e790fdad8aca6bb43900acb3a18db323b8d0eb6 -> skim-0.20.2-7e790fd.tar.gz
https://direct.funtoo.org/6a/e7/fe/6ae7fe26d234e09fae9f169d0f17eee50a9aab525e687ddf81a2be397bf477531da8cdaf9b4380637c3dcdef40f17545611eec91b9de17e1997600b8908afd49 -> skim-0.20.2-funtoo-crates-bundle-4f5c11a0242252df563834a62583af90d6f21867a35c64cc921e6ac859279a31429a258e643528cfd59dcbff212eaeeee4dd172229c5ed7d1d5eb0f1c2ba7dd0.tar.gz"

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