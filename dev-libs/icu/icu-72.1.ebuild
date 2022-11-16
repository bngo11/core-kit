# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Please bump with dev-libs/icu-layoutex

PYTHON_COMPAT=( python3+ )
inherit autotools flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="International Components for Unicode"
HOMEPAGE="https://icu.unicode.org/"

SRC_URI="https://github.com/unicode-org/icu/releases/download/release-${PV//./-}/icu4c-${PV//./_}-src.tgz"
S="${WORKDIR}"/${PN}/source

KEYWORDS="*"

LICENSE="BSD"
SLOT="0/${PV}"
IUSE="debug doc examples static-libs test"
RESTRICT="!test? ( test )"

BDEPEND+="
	${PYTHON_DEPS}
	sys-devel/autoconf-archive
	virtual/pkgconfig
	doc? ( app-doc/doxygen[dot] )
"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/icu-config
)

PATCHES=(
	"${FILESDIR}/${PN}-65.1-remove-bashisms.patch"
	"${FILESDIR}/${PN}-64.2-darwin.patch"
	"${FILESDIR}/${PN}-68.1-nonunicode.patch"
)

src_prepare() {
	default

	# Disable renaming as it assumes stable ABI and that consumers
	# won't use unofficial APIs. We need this despite the configure argument.
	sed -i \
		-e "s/#define U_DISABLE_RENAMING 0/#define U_DISABLE_RENAMING 1/" \
		common/unicode/uconfig.h || die

	# Fix linking of icudata
	sed -i \
		-e "s:LDFLAGSICUDT=-nodefaultlibs -nostdlib:LDFLAGSICUDT=:" \
		config/mh-linux || die

	# Append doxygen configuration to configure
	sed -i \
		-e 's:icudefs.mk:icudefs.mk Doxyfile:' \
		configure.ac || die

	eautoreconf
}

src_configure() {
	MAKEOPTS+=" VERBOSE=1"

	# ICU tries to append -std=c++11 without this, so as of 71.1,
	# despite GCC 9+ using c++14 (or gnu++14) and GCC 11+ using gnu++17,
	# we still need this.
	append-cxxflags -std=c++14

	if tc-is-cross-compiler; then
		mkdir "${WORKDIR}"/host || die
		pushd "${WORKDIR}"/host >/dev/null || die

		CFLAGS="" CXXFLAGS="" ASFLAGS="" LDFLAGS="" \
		CC="$(tc-getBUILD_CC)" CXX="$(tc-getBUILD_CXX)" AR="$(tc-getBUILD_AR)" \
		RANLIB="$(tc-getBUILD_RANLIB)" LD="$(tc-getBUILD_LD)" \
		"${S}"/configure --disable-renaming --disable-debug \
			--disable-samples --enable-static || die
		emake

		popd >/dev/null || die
	fi

	local myeconfargs=(
		--disable-renaming
		--disable-samples
		--disable-layoutex
		$(use_enable debug)
		$(use_enable static-libs static)
		$(use_enable test tests)
		$(multilib_native_use_enable examples samples)
	)

	tc-is-cross-compiler && myeconfargs+=(
		--with-cross-build="${WORKDIR}"/host
	)

	# Work around cross-endian testing failures with LTO #757681
	if tc-is-cross-compiler && is-flagq '-flto*' ; then
		myeconfargs+=( --disable-strict )
	fi

	# ICU tries to use clang by default
	tc-export CC CXX

	# Make sure we configure with the same shell as we run icu-config
	# with, or ECHO_N, ECHO_T and ECHO_C will be wrongly defined
	export CONFIG_SHELL="${EPREFIX}/bin/sh"
	# Probably have no /bin/sh in prefix-chain
	[[ -x ${CONFIG_SHELL} ]] || CONFIG_SHELL="${BASH}"

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

src_compile() {
	default

	if use doc; then
		doxygen -u Doxyfile || die
		doxygen Doxyfile || die
	fi
}

src_test() {
	# INTLTEST_OPTS: intltest options
	#   -e: Exhaustive testing
	#   -l: Reporting of memory leaks
	#   -v: Increased verbosity
	# IOTEST_OPTS: iotest options
	#   -e: Exhaustive testing
	#   -v: Increased verbosity
	# CINTLTST_OPTS: cintltst options
	#   -e: Exhaustive testing
	#   -v: Increased verbosity
	emake -j1 check
}

src_install() {
	default

	if use doc; then
		docinto html
		dodoc -r doc/html/*
	fi

	local HTML_DOCS=( ../readme.html )
	einstalldocs
}
