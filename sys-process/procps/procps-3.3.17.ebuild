# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic multilib-minimal toolchain-funcs usr-ldscript

MY_PN=${PN}-ng
MY_P=${MY_PN}-${PV}
DESCRIPTION="Standard informational utilities and process-handling tools"
HOMEPAGE="https://procps-ng.sourceforge.net https://gitlab.com/procps-ng/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0/8" # libprocps.so
KEYWORDS="*"
IUSE="elogind +kill modern-top +ncurses nls selinux static-libs systemd test unicode"
RESTRICT="!test? ( test )"

DEPEND="
	elogind? ( sys-auth/elogind )
	ncurses? ( >=sys-libs/ncurses-5.7-r7:=[unicode(+)?] )
	selinux? ( sys-libs/libselinux[${MULTILIB_USEDEP}] )
	systemd? ( sys-apps/systemd[${MULTILIB_USEDEP}] )
"
BDEPEND="
	elogind? ( virtual/pkgconfig )
	ncurses? ( virtual/pkgconfig )
	systemd? ( virtual/pkgconfig )
	test? ( dev-util/dejagnu )
"
RDEPEND="${DEPEND}
	kill? (
		!sys-apps/coreutils[kill]
		!sys-apps/util-linux[kill]
	)
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.3.11-sysctl-manpage.patch # 565304
	"${FILESDIR}"/${PN}-3.3.12-proc-tests.patch # 583036
)

#src_prepare() {
#	default
#
#	# Please drop this after 3.3.17 and instead use --disable-w on musl.
#	# bug #794997
#	use elibc_musl && eapply "${FILESDIR}"/${PN}-3.3.17-musl-fix.patch
#}

multilib_src_configure() {
	if tc-is-cross-compiler ; then
		# This isn't ideal but upstream don't provide a placement
		# when malloc is missing anyway, leading to errors like:
		# pslog.c:(.text.startup+0x108): undefined reference to `rpl_malloc'
		# See https://sourceforge.net/p/psmisc/bugs/71/
		# (and https://lists.gnu.org/archive/html/autoconf/2011-04/msg00019.html)
		export ac_cv_func_malloc_0_nonnull=yes \
			ac_cv_func_realloc_0_nonnull=yes
	fi

	# http://www.freelists.org/post/procps/PATCH-enable-transparent-large-file-support
	append-lfs-flags #471102
	local myeconfargs=(
		$(multilib_native_use_with elogind) # No elogind multilib support
		$(multilib_native_use_enable kill)
		$(multilib_native_use_enable modern-top)
		$(multilib_native_use_with ncurses)
		$(use_enable nls)
		$(use_enable selinux libselinux)
		$(use_enable static-libs static)
		$(use_with systemd)
		$(use_enable unicode watch8bit)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_test() {
	emake check </dev/null #461302
}

multilib_src_install() {
	default
	dodoc "${S}"/sysctl.conf

	if multilib_is_native_abi ; then
		dodir /bin
		mv "${ED}"/usr/bin/ps "${ED}"/bin/ || die
		if use kill ; then
			mv "${ED}"/usr/bin/kill "${ED}"/bin/ || die
		fi

		gen_usr_ldscript -a procps
	fi
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -type f -name '*.la' -delete || die
}