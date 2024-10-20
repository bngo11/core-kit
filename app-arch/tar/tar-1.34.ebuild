# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="https://www.gnu.org/software/tar/"
SRC_URI="https://ftp.gnu.org/gnu/tar//tar-1.34.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="acl elibc_glibc minimal nls selinux userland_GNU xattr"

RDEPEND="
	acl? ( virtual/acl )
	selinux? ( sys-libs/libselinux )
"
DEPEND="${RDEPEND}
	xattr? ( elibc_glibc? ( sys-apps/attr ) )
"
BDEPEND="
	nls? ( sys-devel/gettext )
"

src_prepare() {
	default

	if ! use userland_GNU ; then
		sed -i \
			-e 's:/backup\.sh:/gbackup.sh:' \
			scripts/{backup,dump-remind,restore}.in \
			|| die "sed non-GNU"
	fi
}

src_configure() {
	local myeconfargs=(
		--bindir="${EPREFIX}"/bin
		--enable-backup-scripts
		--libexecdir="${EPREFIX}"/usr/sbin
		$(usex userland_GNU "" "--program-prefix=g")
		$(use_with acl posix-acls)
		$(use_enable nls)
		$(use_with selinux)
		$(use_with xattr xattrs)
	)
	FORCE_UNSAFE_CONFIGURE=1 econf "${myeconfargs[@]}"
}

src_install() {
	default

	local p=$(usex userland_GNU "" "g")
	if [[ -z ${p} ]] ; then
		# a nasty yet required piece of baggage
		cat <<-"EOF" > "${T}"/rmt
			#!/bin/sh
			#
			# This is not a mistake.  This shell script (/etc/rmt) has been provided
			# for compatibility with other Unix-like systems, some of which have
			# utilities that expect to find (and execute) rmt in the /etc directory
			# on remote systems.
			#
			exec rmt "$@"
			EOF
		exeinto /etc
		doexe "${T}"/rmt
	fi

	# autoconf looks for gtar before tar (in configure scripts), hence
	# in Prefix it is important that it is there, otherwise, a gtar from
	# the host system (FreeBSD, Solaris, Darwin) will be found instead
	# of the Prefix provided (GNU) tar
	if use prefix ; then
		dosym tar /bin/gtar
	fi

	mv "${ED}"/usr/sbin/${p}backup{,-tar} || die
	mv "${ED}"/usr/sbin/${p}restore{,-tar} || die

	if use minimal ; then
		find "${ED}"/etc "${ED}"/*bin/ "${ED}"/usr/*bin/ \
			-type f -a '!' '(' -name tar -o -name ${p}tar ')' \
			-delete || die
	fi
}