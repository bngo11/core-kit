# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_P="autotools-wrappers-at-${PV}"

DESCRIPTION="Wrapper for autoconf to manage multiple autoconf versions"
HOMEPAGE="https://gitweb.gentoo.org/proj/autotools-wrappers.git"

SRC_URI="https://gitweb.gentoo.org/proj/autotools-wrappers.git/snapshot/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

KEYWORDS="*"

LICENSE="GPL-2"
SLOT="0"

src_prepare() {
	default

	# usr/bin/aclocal: bad substitution -> /bin/sh != POSIX shell
	if use prefix ; then
		sed -i -e '1c\#!'"${EPREFIX}"'/bin/sh' ac-wrapper.sh || die
	fi
}

src_install() {
	exeinto /usr/$(get_libdir)/misc
	doexe ac-wrapper.sh

	dodir /usr/bin
	local x=
	for x in auto{conf,header,m4te,reconf,scan,update} ifnames ; do
		dosym ../$(get_libdir)/misc/ac-wrapper.sh /usr/bin/${x}
	done
}
