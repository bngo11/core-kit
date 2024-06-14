# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="ncurses"
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 eutils linux-info

DESCRIPTION="CLI curses based monitoring tool"
HOMEPAGE="https://github.com/nicolargo/glances"
SRC_URI="https://github.com/nicolargo/glances/archive/v4.0.8.tar.gz -> glances-4.0.8.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	dev-python/defusedxml[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/psutil-5.6.7[${PYTHON_USEDEP}]
	>=dev-python/ujson-5.4.0[${PYTHON_USEDEP}]
	>=dev-python/orjson-3.10.4[${PYTHON_USEDEP}]
"

# PYTHON_USEDEP omitted on purpose
BDEPEND="doc? ( dev-python/sphinx_rtd_theme )"

CONFIG_CHECK="~TASK_IO_ACCOUNTING ~TASK_DELAY_ACCT ~TASKSTATS"

distutils_enable_tests setup.py
distutils_enable_sphinx docs --no-autodoc

pkg_setup() {
	linux-info_pkg_setup
	python-single-r1_pkg_setup
}

python_test() {
	"${EPYTHON}" unittest-core.py || echo "tests failed with ${EPYTHON}"
}

pkg_postinst() {
	optfeature "Autodiscover mode" dev-python/zeroconf
	optfeature "Cloud support" dev-python/requests
	optfeature "Docker monitoring support" dev-python/docker
	optfeature "SVG graph support" dev-python/pygal
	optfeature "IP plugin" dev-python/netifaces
	optfeature "RAID monitoring" dev-python/pymdstat
	optfeature "RAID support" dev-python/pymdstat
	optfeature "SNMP support" dev-python/pysnmp
	optfeature "WIFI plugin" net-wireless/python-wifi
}