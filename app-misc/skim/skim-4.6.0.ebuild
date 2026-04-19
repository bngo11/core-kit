# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/ca986f444c37d2c1dc15ce1fad2fe101776af8d9 -> skim-4.6.0-ca986f4.tar.gz
https://direct.funtoo.org/45/d0/0a/45d00a7d962fa90da43e53194f1bef1ac6413e51cf58506926a9adfd559eabdfc1924d77fab2b4cccc17c44e692450255946b75c1250ae76ff04c9b15fd1cc46 -> skim-4.6.0-funtoo-crates-bundle-245de0342c6ccedc1d34466c385189c0b9fb570d0723b4aa2dcc9f49a7835d85d3a5050e2c2da7ec72aa849a393c50a7e9e88eef71573135fca20ee15624a5db.tar.gz"

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