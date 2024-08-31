# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Funtoo framework for creating initial ramdisks."
HOMEPAGE="https://gitlab.com/shadow5061607/funtoo/funtoo-ramdisk"
SRC_URI=" https://gitlab.com/api/v4/projects/60342138/packages/generic/funtoo-ramdisk/1.1.17/funtoo-ramdisk-1.1.17.tar.gz -> funtoo-ramdisk-1.1.17.tar.gz "

DEPEND=""
RDEPEND="
	app-arch/xz-utils
	app-arch/zstd
	app-misc/pax-utils
	sys-apps/busybox[-pam,static]
	dev-python/rich[${PYTHON_USEDEP}]"
IUSE=""
SLOT="0"
LICENSE="Apache-2.0"
KEYWORDS="*"
S="${WORKDIR}/funtoo_ramdisk-${PV}"

python_install_all() {
	doman ${S}/doc/ramdisk.8
}