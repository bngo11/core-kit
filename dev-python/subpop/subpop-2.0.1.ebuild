# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="A gentle evolution of the POP paradigm."
HOMEPAGE="https://code.funtoo.org/bitbucket/users/drobbins/repos/subpop/browse https://pypi.org/project/subpop/"
SRC_URI="https://gitlab.com/api/v4/projects/60519581/packages/generic/subpop/2.0.1/subpop-2.0.1.tar.gz -> subpop-2.0.1.tar.gz"

DEPEND=""
RDEPEND="dev-python/pyyaml[${PYTHON_USEDEP}]"
IUSE=""
SLOT="0"
LICENSE="Apache-2.0"
KEYWORDS="*"
S="${WORKDIR}/subpop-${PV}"