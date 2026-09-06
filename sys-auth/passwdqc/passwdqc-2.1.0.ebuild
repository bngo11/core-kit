# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic pam toolchain-funcs

DESCRIPTION="Password strength checking library (and PAM module)"
HOMEPAGE="https://www.openwall.com/passwdqc/"
SRC_URI="
	https://www.openwall.com/${PN}/${P}.tar.gz
"

LICENSE="Openwall BSD public-domain"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 ~sparc x86"
IUSE="audit"

RDEPEND="
	sys-libs/pam[audit?]
"
DEPEND="
	${RDEPEND}
	audit? ( sys-process/audit )
"

QA_FLAGS_IGNORED="
	lib*/security/pam_passwdqc.so
	usr/lib*/libpasswdqc.so.1
"

src_prepare() {
	default

	# Don't re-define _F_S / otherwise clash with our default toolchain
	# hardening.
	sed -i \
		-e 's:`uname -s`:Linux:' \
		-e 's:-fPIE.*::' \
		-e 's:-Wl,-z,relro.*::' \
		Makefile || die

	# Ship our own default settings
	cat <<- EOF > "${S}/passwdqc.conf"
		min=disabled,24,11,8,7
		max=72
		passphrase=3
		match=4
		similar=deny
		random=47
		enforce=none
		retry=3
	EOF
}

src_configure() {
	use audit && append-cppflags -DHAVE_LIBAUDIT=1
	default
}

_emake() {
	emake \
		SHARED_LIBDIR="/usr/$(get_libdir)" \
		DEVEL_LIBDIR="/usr/$(get_libdir)" \
		SECUREDIR="$(getpam_mod_dir)" \
		CONFDIR="/etc/security" \
		CFLAGS="${CFLAGS} ${CPPFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		CC="$(tc-getCC)" \
		LD="$(tc-getCC)" \
		"$@"
}

src_compile() {
	_emake all
}

src_install() {
	_emake DESTDIR="${ED}" install_lib install_pam install_utils
	dodoc README PLATFORMS INTERNALS
}
