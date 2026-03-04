# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/17adb040ace91d34a87fc40ac3c6d231cb010dc0 -> skim-3.6.2-17adb04.tar.gz
https://direct.funtoo.org/80/eb/39/80eb3911d39a7125a0dd822122a0b5ccf1d1253aaa79aa2a087757fa1b4923fdf89f6f5d51a6a1e40365837c6aed92d537f5edc8a31d23cadfb53fe6220a6184 -> skim-3.6.2-funtoo-crates-bundle-c803fe4a36caccba2abde6f02a75d78de44bfaec443f5c0415cd5609f1e08360946c78d409fcbeb53e068bef787a5f1269b60e7bd48c9fafb2268d84b20cb10f.tar.gz"

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