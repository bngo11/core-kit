# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/f2ffa801c7eb82a88ef79ddcf5f959e21b1ce9df -> skim-0.17.3-f2ffa80.tar.gz
https://direct.funtoo.org/f8/c9/d0/f8c9d001e5fa2b6cbf446d5e86f82011d096436d52a7f437e51c7ee18d47d96ff9c1a7906cb3727f561af693ac22d201ad98bfb82c4c954cc9f3b527578ea1ec -> skim-0.17.3-funtoo-crates-bundle-1bb9ae54fc944323244c120183393198af6e9a77a4275b616219b7d2d9998f38a5b5aa70e16555686b1e518e8b7aea01a790773f264db407458d061da6063fb8.tar.gz"

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