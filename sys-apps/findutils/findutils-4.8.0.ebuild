# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2+ )

inherit flag-o-matic python-any-r1

DESCRIPTION="GNU utilities for finding files"
HOMEPAGE="https://www.gnu.org/software/findutils/"
SRC_URI="https://ftp.gnu.org/gnu/findutils//findutils-4.8.0.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="nls selinux static test"
RESTRICT="!test? ( test )"

RDEPEND="selinux? ( sys-libs/libselinux )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	test? ( ${PYTHON_DEPS} )
"
BDEPEND="
	app-arch/xz-utils
	nls? ( sys-devel/gettext )
"

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	# Don't build or install locate because it conflicts with mlocate,
	# which is a secure version of locate.  See bug 18729
	sed \
		-e '/^SUBDIRS/s@locate@@' \
		-e '/^built_programs/s@ frcode locate updatedb@@' \
		-i Makefile.in || die

	default
}

src_configure() {
	if use static; then
		append-flags -pthread
		append-ldflags -static
	fi

	program_prefix=$(usex userland_GNU '' g)
	local myeconfargs=(
		--with-packager="Funtoo"
		--with-packager-version="${PVR}"
		--with-packager-bug-reports="https://bugs.funtoo.org/"
		--program-prefix=${program_prefix}
		$(use_enable nls)
		$(use_with selinux)
		--libexecdir='$(libdir)'/find
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	# We don't build locate, but the docs want a file in there.
	emake -C locate dblocation.texi
	default
}