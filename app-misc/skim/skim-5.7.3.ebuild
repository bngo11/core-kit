# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/f7dba15d998b347d8c9500f6f89f1f053ae0cb8a -> skim-5.7.3-f7dba15.tar.gz
https://direct.funtoo.org/78/71/29/787129f152bfd2bbf95e674fbed578b289676c10fb447357e80a70c19c69af955ffbc938a14914ace995e462737f0beee08d3923c32052e1d0598b4b1f1cc6e3 -> skim-5.7.3-funtoo-crates-bundle-0459fd45ea3efecb53e057078a9d773e3eede127d37bc152dd08bcd5be171bd31fdbbb73bc63354d19836f81132b74f620f2aaaa36f3d68ed8711904c56eecbb.tar.gz"

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