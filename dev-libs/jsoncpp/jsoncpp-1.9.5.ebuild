# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit meson python-any-r1

DESCRIPTION="C++ JSON reader and writer"
HOMEPAGE="https://github.com/open-source-parsers/jsoncpp"
SRC_URI="https://api.github.com/repos/open-source-parsers/jsoncpp/tarball/1.9.5 -> jsoncpp-1.9.5.tar.gz"

LICENSE="|| ( public-domain MIT )"
SLOT="0/24"
KEYWORDS="*"
IUSE="doc test"
RESTRICT="!test? ( test )"

BDEPEND="
	${PYTHON_DEPS}
	doc? ( app-doc/doxygen )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/open-source-parsers-jsoncpp-* "${S}" || die
}

src_configure() {
	local emesonargs=(
		# Follow Debian, Ubuntu, Arch convention for headers location
		# bug #452234
		--includedir include/jsoncpp
		-Dtests=$(usex test true false)
	)
	meson_src_configure
}

src_compile() {
	meson_src_compile

	if use doc; then
		echo "${PV}" > version || die
		"${EPYTHON}" doxybuild.py --doxygen="${EPREFIX}"/usr/bin/doxygen || die
		HTML_DOCS=( dist/doxygen/jsoncpp*/. )
	fi
}