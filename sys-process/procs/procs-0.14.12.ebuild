# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="A modern replacement for ps written in Rust"
HOMEPAGE="https://github.com/dalance/procs"
SRC_URI="https://github.com/dalance/procs/tarball/9465f02499d02a05076856a09c5a96dffcce3298 -> procs-0.14.12-9465f02.tar.gz
https://direct.funtoo.org/d6/09/87/d60987a3863eae4f4cde66bd18d6ec51f75062139bf264aecd88760819b387e5bac26098169b47f38bc2dd8d154d883d6480fe19ad19a7de62e13ed2df23d74f -> procs-0.14.12-funtoo-crates-bundle-db4bba4ce320c0a8d079179b7124b16035e8f305e2f71742483fb4eeaf6cf53337ec0b1b07782e787b1ff65332979d9091e26bf28265e1292c3b94fec00e682d.tar.gz"

LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 MIT ZLIB"
SLOT="0"
KEYWORDS="*"

BDEPEND="virtual/rust"

src_unpack() {
	cargo_src_unpack
	rm -rf ${S}
	mv ${WORKDIR}/dalance-procs-* ${S} || die
}

src_install() {
	# Avoid calling doman from eclass. It fails.
	rm -rf ${S}/man
	cargo_src_install
	dodoc README.md
}