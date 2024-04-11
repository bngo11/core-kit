# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="A modern replacement for ps written in Rust"
HOMEPAGE="https://github.com/dalance/procs"
SRC_URI="https://github.com/dalance/procs/tarball/4f1f6ab87c8f10e7369c1b730d946f333b0fb64c -> procs-0.14.5-4f1f6ab.tar.gz
https://direct.funtoo.org/3a/06/98/3a06989e634c984e02fe55b46245462f2ac5a10bb50ce0291b96ff19f1100a079036f72ee7e776cacaa09b35ab7381879a8c4531a385df86f2ce620bc17efdf0 -> procs-0.14.5-funtoo-crates-bundle-092e92061c85073f98abfeb1952e66e19db623d838a42c5f9b62a15c654e2e2b9268b4be4da5464dfef6b29fe972c7403d2498634f51a0272a5a2d0253dee292.tar.gz"

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