# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="A modern replacement for ps written in Rust"
HOMEPAGE="https://github.com/dalance/procs"
SRC_URI="https://github.com/dalance/procs/tarball/4f1f6ab87c8f10e7369c1b730d946f333b0fb64c -> procs-0.14.5-4f1f6ab.tar.gz
https://direct.funtoo.org/69/45/dc/6945dcab390228f1902a8a7b1aef6d6b855a2b0ee17f9b8b876e620ba970b52fe0602baf0ba4ec9033d16900861e85f7837fb176659943db8021d2d2e47207e9 -> procs-0.14.5-funtoo-crates-bundle-092e92061c85073f98abfeb1952e66e19db623d838a42c5f9b62a15c654e2e2b9268b4be4da5464dfef6b29fe972c7403d2498634f51a0272a5a2d0253dee292.tar.gz"

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