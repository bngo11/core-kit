# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

DESCRIPTION="A modern replacement for ps written in Rust"
HOMEPAGE="https://github.com/dalance/procs"
SRC_URI="https://github.com/dalance/procs/tarball/2a0ba5c900b90a510a7fd1f21f8efe4b827c4b22 -> procs-0.14.9-2a0ba5c.tar.gz
https://direct.funtoo.org/b1/9b/a4/b19ba41858d9527fa14347962f73d888f94e300a106d5a2e74c4e5c1f7f2f556cde0deb5a0e13071f21cf0075ac4622a67b993493c9a95f8ce99eae1b52d2847 -> procs-0.14.9-funtoo-crates-bundle-e11585914c4ac140700fb8c0feaf33a23a9206a265eb20db6fd6a24e5272dd1c605a5ccc1d370cb993d566ed2b3d4e0bb46ecc31dc40facf5e0a66aaefaba02f.tar.gz"

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