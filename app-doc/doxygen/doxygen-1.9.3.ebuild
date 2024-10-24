# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit cmake-utils eutils python-any-r1

DESCRIPTION="Documentation system for most programming languages"
HOMEPAGE=""https://www.doxygen.nl/
SRC_URI="https://api.github.com/repos/doxygen/doxygen/tarball/refs/tags/Release_1_9_3 -> doxygen-1.9.3.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="*"
IUSE="clang debug doc dot doxysearch latex qt5 sqlite userland_GNU"

RDEPEND="app-text/ghostscript-gpl
	dev-lang/perl
	media-libs/libpng:0=
	virtual/libiconv
	clang? ( >=sys-devel/clang-4.0.0:= )
	dot? (
		media-gfx/graphviz
		media-libs/freetype
	)
	doxysearch? ( dev-libs/xapian:= )
	latex? (
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
	qt5? (
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/qtxml:5
	)
	sqlite? ( dev-db/sqlite:3 )
	"

REQUIRED_USE="doc? ( latex )"

DEPEND="sys-devel/flex
	sys-devel/bison
	doc? ( ${PYTHON_DEPS} )
	${RDEPEND}"

# src_test() defaults to make -C testing but there is no such directory (bug #504448)
RESTRICT="test"

PATCHES=(
	"${FILESDIR}/${PN}-1.8.16-link_with_pthread.patch"
	"${FILESDIR}/${PN}-1.9.1-ignore-bad-encoding.patch"
)

DOCS=( LANGUAGE.HOWTO README.md )

pkg_setup() {
	use doc && python-any-r1_pkg_setup
}

src_unpack() {
	unpack "${A}"
	mv "${WORKDIR}"/doxygen-doxygen-* "${S}" || die
}

src_prepare() {
	cmake-utils_src_prepare

	# Statically link internal xml library
	sed -i -e '/add_library/s/$/ STATIC/' libxml/CMakeLists.txt || die

	# Call dot with -Teps instead of -Tps for EPS generation - bug #282150
	sed -i -e '/addJob("ps"/ s/"ps"/"eps"/g' src/dot.cpp || die

	# fix pdf doc
	sed -i.orig -e "s:g_kowal:g kowal:" \
		doc/maintainers.txt || die

	if is-flagq "-O3" ; then
		ewarn
		ewarn "Compiling with -O3 is known to produce incorrectly"
		ewarn "optimized code which breaks doxygen."
		ewarn
		elog
		elog "Continuing with -O2 instead ..."
		elog
		replace-flags "-O3" "-O2"
	fi
}

src_configure() {
	local mycmakeargs=(
		-Duse_libclang=$(usex clang)
		-Dbuild_doc=$(usex doc)
		-Dbuild_search=$(usex doxysearch)
		-Dbuild_wizard=$(usex qt5)
		-Duse_sqlite3=$(usex sqlite)
		)
	use doc && mycmakeargs+=(
		-DDOC_INSTALL_DIR="share/doc/${P}"
		)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		export VARTEXFONTS="${T}/fonts" # bug #564944

		if ! use dot; then
			sed -i -e "s/HAVE_DOT               = YES/HAVE_DOT    = NO/" \
				{Doxyfile,doc/Doxyfile} \
				|| die "disabling dot failed"
		fi
		cmake-utils_src_make -C "${BUILD_DIR}" docs
	fi
}

src_install() {
	cmake-utils_src_install
}