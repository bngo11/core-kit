# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit libtool flag-o-matic qmake-utils toolchain-funcs

DESCRIPTION="GnuPG Made Easy is a library for making GnuPG easier to use"
HOMEPAGE="https://www.gnupg.org/related_software/gpgme"
SRC_URI="https://gnupg.org/ftp/gcrypt/gpgme/gpgme-2.1.1.tar.bz2 -> gpgme-2.1.1.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="1/45.0"
KEYWORDS="*"
IUSE="common-lisp static-libs test"
RESTRICT="!test? ( test )"

# - On each bump, update dep bounds on each version from configure.ac!
# - Quirky libgpg-error dep for bug #699206 (change in recent libgpg-error
#   made gpgme stop installing gpgme-config)
RDEPEND="app-crypt/gnupg
	dev-libs/libassuan
	>=dev-libs/libgpg-error-1.47
"
DEPEND="${RDEPEND}
"

src_prepare() {
	default

	elibtoolize

	# bug #697456
	addpredict /run/user/$(id -u)/gnupg

	local MAX_WORKDIR=66
	if use test && [[ "${#WORKDIR}" -gt "${MAX_WORKDIR}" ]]; then
		eerror "Unable to run tests as WORKDIR='${WORKDIR}' is longer than ${MAX_WORKDIR} which causes failure!"
		die "Could not run tests as requested with too-long WORKDIR."
	fi

	# Make best effort to allow longer PORTAGE_TMPDIR
	# as usock limitation fails build/tests
	ln -s "${P}" "${WORKDIR}/b" || die
	S="${WORKDIR}/b"
}

src_configure() {
	local languages=()

	use common-lisp && languages+=( "cl" )

	# bug #847955
	append-lfs-flags

	econf \
		$(use test || echo "--disable-gpgconf-test --disable-gpg-test --disable-gpgsm-test --disable-g13-test") \
		--enable-languages="${languages[*]}" \
		$(use_enable static-libs static)
}

src_install() {
	default

	find "${ED}" -type f -name '*.la' -delete || die

	# Backward compatibility for gentoo
	# (in the past, we had slots)
	dodir /usr/include/gpgme
	dosym ../gpgme.h /usr/include/gpgme/gpgme.h
}