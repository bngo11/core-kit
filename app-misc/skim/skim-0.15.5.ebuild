# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/1121509428a6e4ada14a7d852075bd99ff17369e -> skim-0.15.5-1121509.tar.gz
https://direct.funtoo.org/89/9b/6f/899b6f78488e9e768194db383c19dff3a44cc1bf081aa73c3993520c1bccf0b7d278c860646003bf2fca053d9217ccda339fd89a8d0231e345ef67dd5f2f76f6 -> skim-0.15.5-funtoo-crates-bundle-4966630b20aa9015b0528584456249b216eb68e7290b3c8509048861943e5d26839626b33606fd9b0005187f13658001bbaacff9f33b5befe6523c6082b85bbf.tar.gz"

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