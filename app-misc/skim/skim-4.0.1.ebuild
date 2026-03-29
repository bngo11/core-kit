# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/90e23eb86e58adde2e52eba30d3bc8fa483ce54e -> skim-4.0.1-90e23eb.tar.gz
https://direct.funtoo.org/68/7b/e2/687be229f02039967d52185b42ea2a438664b4d96d72068c75ae2d58c51fcc379dea15c881b46e256f943e678c94e2bb621f93b60779baa92873f5d53a03f2de -> skim-4.0.1-funtoo-crates-bundle-66d75c6e9ac65169acd4b705afc427469375c23d20d1558aa6af890cc95beee29d81c48c0fba22d00cb8dd8036cb4855429030b14c0734636e5a3ae779c4a8cc.tar.gz"

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