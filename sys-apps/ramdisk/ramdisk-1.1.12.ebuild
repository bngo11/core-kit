# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Funtoo framework for creating initial ramdisks."
HOMEPAGE="https://code.funtoo.org/bitbucket/users/drobbins/repos/funtoo-ramdisk/browse https://pypi.org/project/funtoo-ramdisk/"
SRC_URI="https://files.pythonhosted.org/packages/9e/ce/7c04365fbf5d695161ed4c15b3e57132d53be60d721dac2615712574f54c/funtoo_ramdisk-1.1.12.tar.gz -> funtoo_ramdisk-1.1.12.tar.gz"

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
S="${WORKDIR}/funtoo_ramdisk-1.1.12"

python_install_all() {
	doman ${S}/doc/ramdisk.8
}
