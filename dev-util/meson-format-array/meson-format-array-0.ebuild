# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit edo python-r1

DESCRIPTION="Format shell expressions into a meson array"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}"

src_test() {
	run_doctest() {
		edo ${EPYTHON} -B -m doctest "${FILESDIR}/meson-format-array.py"
	}
	python_foreach_impl run_doctest
}

src_install() {
	python_foreach_impl python_newscript "${FILESDIR}"/meson-format-array.py meson-format-array
}
