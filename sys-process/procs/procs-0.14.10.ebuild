# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="A modern replacement for ps written in Rust"
HOMEPAGE="https://github.com/dalance/procs"
SRC_URI="https://github.com/dalance/procs/tarball/929508694329e0a66cbc220965f1cd57693db82f -> procs-0.14.10-9295086.tar.gz
https://direct.funtoo.org/72/78/26/727826ef84957f476d902061dac75017f08474aec5e847da3cc40bcc4b9147ef4445af9965baa78369fd8b1ac543ee2661938c4dafabe498b0d04c46049af541 -> procs-0.14.10-funtoo-crates-bundle-746f014d4e7657caa322df0dbb86124d8b565c27e9574717f53eefb020cdc77e55e127081dfe6e66138d19adcb79d41a77081d89e3fc34808df3942293d68459.tar.gz"

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