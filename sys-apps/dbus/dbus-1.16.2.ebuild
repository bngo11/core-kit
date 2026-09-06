# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit meson flag-o-matic linux-info python-any-r1 readme.gentoo-r1 systemd virtualx user

DESCRIPTION="A message bus system, a simple way for applications to talk to each other"
HOMEPAGE="https://dbus.freedesktop.org/"
SRC_URI="https://dbus.freedesktop.org/releases/dbus/${P}.tar.xz"

LICENSE="|| ( AFL-2.1 GPL-2 )"
SLOT="0"
KEYWORDS="*"
IUSE="apparmor audit debug doc kernel_linux selinux static-libs systemd test user-session valgrind X"

REQUIRED_USE=""

BDEPEND="
	app-text/xmlto
	app-text/docbook-xml-dtd:4.4
	sys-devel/autoconf-archive
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"
COMMON_DEPEND="
	>=dev-libs/expat-2.1.0
	sys-auth/elogind
	selinux? ( sys-libs/libselinux )
	systemd? ( sys-apps/systemd:0= )
	X? (
		x11-libs/libX11
		x11-libs/libXt
	)
"
DEPEND="${COMMON_DEPEND}
	dev-libs/expat
	test? (
		${PYTHON_DEPS}
		>=dev-libs/glib-2.40:2
	)
"
RDEPEND="${COMMON_DEPEND}
	selinux? ( sec-policy/selinux-dbus )
"

DOC_CONTENTS="
	Some applications require a session bus in addition to the system
	bus. Please see \`man dbus-launch\` for more information.
"

# out of sources build dir for make check
TBD="${WORKDIR}/${P}-tests-build"

PATCHES=(
	"${FILESDIR}/${PN}-1.16.0-enable-elogind.patch"
)

pkg_setup() {
	enewgroup messagebus
	enewuser messagebus -1 -1 -1 messagebus

	use test && python-any-r1_pkg_setup

	if use kernel_linux; then
		CONFIG_CHECK="~EPOLL"
		linux-info_pkg_setup
	fi
}

src_configure() {
	local rundir=$(usex kernel_linux /run /var/run)
	sed -e "s;@rundir@;${EPREFIX}${rundir};g" "${FILESDIR}"/dbus.initd.in \
		> "${T}"/dbus.initd || die

	local emesonargs=(
		--localstatedir="${EPREFIX}/var"
		-Druntime_dir="${EPREFIX}${rundir}"
		-Ddefault_library=$(usex static-libs both shared)
		-Dasserts=false # TODO
		-Dchecks=false # TODO
		$(meson_use debug stats)
		$(meson_use debug verbose_mode)
		-Ddbus_user=messagebus
		-Dkqueue=disabled
		$(meson_feature kernel_linux inotify)
		$(meson_feature doc doxygen_docs)
		-Dxml_docs=enabled
		-Dinstalled_tests=false
		-Delogind=enabled
		-Dsystemd=disabled
		-Dmessage_bus=true
		$(meson_feature test modular_tests)
		-Dqt_help=disabled
		-Dtools=true

		$(meson_use systemd user_session)
		$(meson_feature X x11_autolaunch)
		$(meson_feature valgrind)
		$(meson_feature apparmor)
		$(meson_feature audit libaudit)
		$(meson_feature selinux)

		-Dsession_socket_dir="${EPREFIX}"/tmp
		-Dsystem_pid_file="${EPREFIX}${rundir}"/dbus.pid
		-Dsystem_socket="${EPREFIX}${rundir}"/dbus/system_bus_socket
		-Dsystemd_system_unitdir="$(systemd_get_systemunitdir)"
		-Dsystemd_user_unitdir="$(systemd_get_userunitdir)"
	)

	if [[ ${CHOST} == *-darwin* ]]; then
		emesonargs+=(
			-Dlaunchd=enabled
			-Dlaunchd_agent_dir="${EPREFIX}"/Library/LaunchAgents
		)
	fi

	meson_src_configure
}

src_compile() {
	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access

	meson_src_compile
}

src_test() {
	DBUS_TEST_MALLOC_FAILURES=0 DBUS_VERBOSE=1 virtx meson_src_test
}

src_install() {
	meson_src_install

	newinitd "${T}"/dbus.initd dbus
	exeinto /etc/user/init.d
	newexe "${FILESDIR}/dbus.user.initd" dbus

	if use X; then
		# dbus X session script (#77504)
		# turns out to only work for GDM (and startx). has been merged into
		# other desktop (kdm and such scripts)
		exeinto /etc/X11/xinit/xinitrc.d
		doexe "${FILESDIR}"/80-dbus
	fi

	# needs to exist for dbus sessions to launch
	keepdir /usr/share/dbus-1/services
	keepdir /etc/dbus-1/{session,system}.d
	# machine-id symlink from pkg_postinst()
	keepdir /var/lib/dbus
	# let the init script create the /var/run/dbus directory
	rm -rf "${ED}"/var/run

	dodoc AUTHORS NEWS README doc/TODO
	readme.gentoo_create_doc

	mv "${ED}"/usr/share/doc/dbus/* "${ED}"/usr/share/doc/${PF}/ || die
	rm -rf "${ED}"/usr/share/doc/dbus || die
	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	readme.gentoo_print_elog

	# Ensure unique id is generated and put it in /etc wrt #370451 but symlink
	# for DBUS_MACHINE_UUID_FILE (see tools/dbus-launch.c) and reverse
	# dependencies with hardcoded paths (although the known ones got fixed already)
	dbus-uuidgen --ensure="${EROOT}"/etc/machine-id
	ln -sf "${EPREFIX}"/etc/machine-id "${EROOT}"/var/lib/dbus/machine-id

	if [[ ${CHOST} == *-darwin* ]]; then
		local plist="org.freedesktop.dbus-session.plist"
		elog
		elog
		elog "For MacOS/Darwin we now ship launchd support for dbus."
		elog "This enables autolaunch of dbus at session login and makes"
		elog "dbus usable under MacOS/Darwin."
		elog
		elog "The launchd plist file ${plist} has been"
		elog "installed in ${EPREFIX}/Library/LaunchAgents."
		elog "For it to be used, you will have to do all of the following:"
		elog " + cd ~/Library/LaunchAgents"
		elog " + ln -s ${EPREFIX}/Library/LaunchAgents/${plist}"
		elog " + logout and log back in"
		elog
		elog "If your application needs a proper DBUS_SESSION_BUS_ADDRESS"
		elog "specified and refused to start otherwise, then export the"
		elog "the following to your environment:"
		elog " DBUS_SESSION_BUS_ADDRESS=\"launchd:env=DBUS_LAUNCHD_SESSION_BUS_SOCKET\""
	fi

	if use user-session; then
		ewarn "You have enabled user-session. Please note this can cause"
		ewarn "bogus behaviors in several dbus consumers that are not prepared"
		ewarn "for this dbus activation method yet."
		ewarn
		ewarn "See the following link for background on this change:"
		ewarn "https://lists.freedesktop.org/archives/systemd-devel/2015-January/027711.html"
		ewarn
		ewarn "Known issues are tracked here:"
		ewarn "https://bugs.gentoo.org/show_bug.cgi?id=576028"
	fi
}
