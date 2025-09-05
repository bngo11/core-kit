# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit python-single-r1

DESCRIPTION="Linux CLI tool providing real-time system resource monitoring"
HOMEPAGE="https://github.com/scottchiefbaker/dool"
SRC_URI="https://github.com/scottchiefbaker/dool/tarball/b74503e2dfbca8ef01c284d40aa77dc82be308b9 -> dool-1.3.8-b74503e.tar.gz"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${PYTHON_DEPS}"

IUSE=""
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="*"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/scottchiefbaker-dool* "${S}" || die
	fi
}

src_compile() {
	${S}/install.py
}

DOCS=( AUTHORS ChangeLog README.md )

src_install() {
	python_doexe ${S}/dool

	python_moduleinto dool
	python_domodule ${S}/plugins/*.py

	doman ${S}/docs/dool.1
	dodoc "${DOCS[@]}"
}