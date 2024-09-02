# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION=""
HOMEPAGE=""

DEPEND="app-arch/brotli"
RDEPEND="${DEPEND}"
IUSE=""
SLOT="0"
LICENSE=""
KEYWORDS="*"
S="${WORKDIR}/brotli-${PV}"

src_unpack() {
	unpack ${ROOT}/usr/share/brotli/bindings/brotli-python-${PV}.tar.gz || die
}