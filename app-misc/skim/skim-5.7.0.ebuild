# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/dd3b09a687c6cad6e1789ecf2aa0f321285fdd5c -> skim-5.7.0-dd3b09a.tar.gz
https://direct.funtoo.org/ba/e9/b7/bae9b781bc54930cfd9f4065c7db33d4648b5b33f45f7a7d61158db150cad629b50c34a8e2bb9294566746b5baac7a841885b55ccb9d5676d101420eef6856be -> skim-5.7.0-funtoo-crates-bundle-60b3e2848c36b32d06d0958c4571e851710f8e986d2790c027e985de26224ad7c120e62c0e2642c6e286a7c19bb81c9822cb1ffad0d38f9672550c1a567d801a.tar.gz"

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