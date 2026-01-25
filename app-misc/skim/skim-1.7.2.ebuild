# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="Fuzzy Finder in rust!"
HOMEPAGE="https://github.com/lotabout/skim"
SRC_URI="https://github.com/lotabout/skim/tarball/8cf06ab256e6bc14d5799c4cf2ebe640e3bfa04a -> skim-1.7.2-8cf06ab.tar.gz
https://direct.funtoo.org/46/0d/4c/460d4ccffebde2d8c2cd0a5aaf87ce932c1c0ef5552c016d007a18798537d7fd043ed6e103c6faee08a9e6a969ba52103e21fedbab1b4294e9d5fe7700017e47 -> skim-1.7.2-funtoo-crates-bundle-9d45cb0470156af40842d9d6fa9edb4a0c8b3ea8aeaaed224c54c2dddbc06d6c5eebbd9f746de2c8fa69c399e5ae844973875003e19f6f16eeb50981674828d3.tar.gz"

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