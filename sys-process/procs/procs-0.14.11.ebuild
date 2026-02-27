# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="A modern replacement for ps written in Rust"
HOMEPAGE="https://github.com/dalance/procs"
SRC_URI="https://github.com/dalance/procs/tarball/049bd052e37e5382f10c04c913e64b4af375a7ea -> procs-0.14.11-049bd05.tar.gz
https://direct.funtoo.org/d4/c4/61/d4c461f5699cf9f5da843cd0146eb35abae201f02fc952ca224f5f09fc11e3f7a92885eff5845a8ad1a8e92bfc8290ee6a37f651109ef704802f000f80b962e9 -> procs-0.14.11-funtoo-crates-bundle-ab11d5a5cd996300824c9308279caaefb2c9b9fa4078717a29907126b76a8291663f66e2a6d611cce1adb34d6f6a19792f125e100d48cf56c533f41805118810.tar.gz"

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