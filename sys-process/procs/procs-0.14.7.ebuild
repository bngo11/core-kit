# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="A modern replacement for ps written in Rust"
HOMEPAGE="https://github.com/dalance/procs"
SRC_URI="https://github.com/dalance/procs/tarball/f96587368dc871a1ee502433621b5c9142a8d066 -> procs-0.14.7-f965873.tar.gz
https://direct.funtoo.org/5d/9b/ff/5d9bffe19e03578b277e26e57b1d80265f580c0173157cd04d0a7306ac00b7f92e4c0519edd9b27bb44f348d3843322179584007014dd628175c77c6d14a2d4a -> procs-0.14.7-funtoo-crates-bundle-5bb01c99503ec810be9dec500ddbcb53256a1e135c5d950aa872dc2509031d3a44779a47e95900b6a81dd4834af915963e6f5ef134906678c5e37982526ad29c.tar.gz"

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