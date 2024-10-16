# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

DESCRIPTION="Super-useful stream editor"
HOMEPAGE="http://sed.sourceforge.net/"
SRC_URI="https://ftp.gnu.org/gnu/sed//sed-4.8.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="acl nls selinux static"

RDEPEND="
	!static? (
		acl? ( virtual/acl )
		nls? ( virtual/libintl )
		selinux? ( sys-libs/libselinux )
	)
"
DEPEND="${RDEPEND}
	static? (
		acl? ( virtual/acl[static-libs(+)] )
		nls? ( virtual/libintl[static-libs(+)] )
		selinux? ( sys-libs/libselinux[static-libs(+)] )
	)
"
BDEPEND="
	app-arch/xz-utils
	nls? ( sys-devel/gettext )
"

src_prepare() {
	# make sure system-sed works #40786
	if ! type -p sed > /dev/null ; then
		mkdir -p "${T}/bootstrap"
		printf '#!/bin/sh\nexec busybox sed "$@"\n' > "${T}/bootstrap/sed" || die
		chmod a+rx "${T}/bootstrap/sed"
		PATH="${T}/bootstrap:${PATH}"
	fi

	default
}

src_configure() {
	local myconf=()
	if use userland_GNU; then
		myconf+=( --exec-prefix="${EPREFIX}" )
	else
		myconf+=( --program-prefix=g )
	fi

	use static && append-ldflags -static
	myconf+=(
		$(use_enable acl)
		$(use_enable nls)
		$(use_with selinux)
	)
	econf "${myconf[@]}"
}