# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit libtool

DESCRIPTION="A secure communications library implementing the SSL, TLS and DTLS protocols"
HOMEPAGE="https://www.gnutls.org/"
SRC_URI="mirror://gnupg/gnutls/v$(ver_cut 1-2)/${P}.tar.xz"

LICENSE="GPL-3 LGPL-2.1+"
# As of 3.8.0, the C++ library is header-only, but we won't drop the subslot
# component for it until libgnutls.so breaks ABI, to avoid pointless rebuilds.
SLOT="0/30" # libgnutls.so number
KEYWORDS="*"
IUSE="brotli +cxx dane doc examples +idn nls +openssl +pkcs11 seccomp sslv2 sslv3 static-libs test test-full +tls-heartbeat tools valgrind"

REQUIRED_USE="
	test-full? ( cxx dane doc examples idn nls openssl pkcs11 seccomp tls-heartbeat tools )"
RESTRICT="!test? ( test )"

RDEPEND=">=dev-libs/libtasn1-4.9:=
	dev-libs/libunistring:=
	>=dev-libs/nettle-3.6:=[gmp]
	>=dev-libs/gmp-5.1.3-r1:=
	brotli? ( >=app-arch/brotli-1.0.9:= )
	tools? ( sys-devel/autogen:= )
	dane? ( >=net-dns/unbound-1.4.20:= )
	nls? ( >=virtual/libintl-0-r1:= )
	pkcs11? ( >=app-crypt/p11-kit-0.23.1:= )
	idn? ( >=net-dns/libidn2-0.16-r1:= )"
DEPEND="${RDEPEND}
	test? (
		seccomp? ( sys-libs/libseccomp )
	)"
BDEPEND=">=virtual/pkgconfig-0-r1
	doc? ( dev-util/gtk-doc )
	nls? ( sys-devel/gettext )
	tools? ( sys-devel/autogen )
	valgrind? ( dev-util/valgrind )
	test-full? (
		app-crypt/dieharder
		>=app-misc/datefudge-1.22
		dev-libs/softhsm:2[-bindist]
		net-dialup/ppp
		net-misc/socat
	)"

DOCS=(
	README.md
	doc/certtool.cfg
)

HTML_DOCS=()

src_prepare() {
	default

	# bug #520818
	export TZ=UTC

	use doc && HTML_DOCS+=( doc/gnutls.html )
}

src_configure() {
	LINGUAS="${LINGUAS//en/en@boldquot en@quot}"

	local libconf=()

	# TPM needs to be tested before being enabled
	libconf+=(
		--without-tpm
		--without-tpm2
	)

	# hardware-accel is disabled on OSX because the asm files force
	#   GNU-stack (as doesn't support that) and when that's removed ld
	#   complains about duplicate symbols
	[[ ${CHOST} == *-darwin* ]] && libconf+=( --disable-hardware-acceleration )

	# Cygwin as does not understand these asm files at all
	[[ ${CHOST} == *-cygwin* ]] && libconf+=( --disable-hardware-acceleration )

	# -fanalyzer substantially slows down the build and isn't useful for
	# us. It's useful for upstream as it's static analysis, but it's not
	# useful when just getting something built.
	export gl_cv_warn_c__fanalyzer=no

	local myeconfargs=(
		$(enable manpages)
		$(use_enable doc gtk-doc)
		$(use_enable doc)
		$(use_enable seccomp seccomp-tests)
		$(use_enable test tests)
		$(use_enable test-full full-test-suite)
		$(use_enable tools)
		$(use_enable valgrind valgrind-tests)
		$(use_enable cxx)
		$(use_enable dane libdane)
		$(use_enable nls)
		$(use_enable openssl openssl-compatibility)
		$(use_enable sslv2 ssl2-support)
		$(use_enable sslv3 ssl3-support)
		$(use_enable static-libs static)
		$(use_enable tls-heartbeat heartbeat-support)
		$(use_with brotli)
		$(use_with idn)
		$(use_with pkcs11 p11-kit)
		--disable-rpath
		--with-default-trust-store-file="${EPREFIX}/etc/ssl/certs/ca-certificates.crt"
		--with-unbound-root-key-file="${EPREFIX}/etc/dnssec/root-anchors.txt"
		--without-included-libtasn1
		$("${S}/configure" --help | grep -o -- '--without-.*-prefix')
	)

	ECONF_SOURCE="${S}" econf "${libconf[@]}" "${myeconfargs[@]}"
}

src_install() {
	default
	einstalldocs
	find "${ED}" -type f -name '*.la' -delete || die

	if use examples; then
		docinto examples
		dodoc doc/examples/*.c
	fi
}
