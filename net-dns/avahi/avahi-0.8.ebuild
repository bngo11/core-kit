# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python3_{6,7,8} )
PYTHON_REQ_USE="gdbm"
inherit autotools flag-o-matic mono-env python-r1 systemd user

DESCRIPTION="System which facilitates service discovery on a local network"
HOMEPAGE="http://avahi.org/"
SRC_URI="https://github.com/lathiat/avahi/archive/v0.8.tar.gz -> avahi-0.8.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="autoipd bookmarks +dbus doc gdbm gtk howl-compat -introspection ipv6 kernel_linux +mdnsresponder-compat mono nls python qt5 selinux systemd test"

REQUIRED_USE="
	python? ( dbus gdbm ${PYTHON_REQUIRED_USE} )
	mono? ( dbus )
	howl-compat? ( dbus )
	mdnsresponder-compat? ( dbus )
	systemd? ( dbus )
"

RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/libdaemon
	dev-libs/libevent:=
	dev-libs/expat
	dev-libs/glib:2
	gdbm? ( sys-libs/gdbm:= )
	qt5? ( dev-qt/qtcore:5 )
	gtk?  ( x11-libs/gtk+:3 )
	dbus? ( sys-apps/dbus )
	kernel_linux? ( sys-libs/libcap )
	introspection? ( dev-libs/gobject-introspection:= )
	mono? (
		dev-lang/mono
		gtk? ( dev-dotnet/gtk-sharp:2 )
	)
	python? (
		${PYTHON_DEPS}
		dbus? ( dev-python/dbus-python[${PYTHON_USEDEP}] )
		introspection? ( dev-python/pygobject:3[${PYTHON_USEDEP}] )
	)
	bookmarks? (
		${PYTHON_DEPS}
		>=dev-python/twisted-16.0.0[${PYTHON_USEDEP}]
	)
"
RDEPEND="
	${DEPEND}
	selinux? ( sec-policy/selinux-avahi )
"

BDEPEND="
	dev-util/glib-utils
	doc? ( app-doc/doxygen )
	app-doc/xmltoman
	dev-util/intltool
	virtual/pkgconfig
"

pkg_preinst() {
	enewgroup netdev
	enewgroup avahi
	enewuser avahi -1 -1 -1 avahi

	if use autoipd; then
		enewgroup avahi-autoipd
		enewuser avahi-autoipd -1 -1 -1 avahi-autoipd
	fi
}

pkg_setup() {
	use mono && mono-env_pkg_setup
	use python || use bookmarks && python_setup
}

src_prepare() {
	default

	if ! use ipv6; then
		sed -i \
			-e "s/use-ipv6=yes/use-ipv6=no/" \
			avahi-daemon/avahi-daemon.conf || die
	fi

	sed -i \
		-e "s:\\.\\./\\.\\./\\.\\./doc/avahi-docs/html/:../../../doc/${PF}/html/:" \
		doxygen_to_devhelp.xsl || die
	eautoreconf
}

src_configure() {
	# those steps should be done once-per-ebuild rather than per-ABI
	use sh && replace-flags -O? -O0

	local myconf=(
		--disable-monodoc
		--disable-python-dbus
		--disable-qt3
		--disable-qt4
		--disable-static
		--enable-manpages
		--enable-glib
		--enable-gobject
		--enable-xmltoman
		--localstatedir="${EPREFIX}/var"
		--with-distro=gentoo
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		--disable-gtk2
		$(use_enable dbus)
		$(use_enable gdbm)
		$(use_enable gtk  gtk3)
		$(use_enable howl-compat compat-howl)
		$(use_enable mdnsresponder-compat compat-libdns_sd)
		$(use_enable nls)
		$(use_enable autoipd)
		$(use_enable doc doxygen-doc)
		$(use_enable introspection)
		$(use_enable mono)
		$(use_enable python)
		$(use_enable test tests)
	)

	if use python; then
		myconf+=(
			$(use_enable dbus python-dbus)
			$(use_enable introspection pygobject)
		)
	fi

	if use mono; then
		myconf+=( $(use_enable doc monodoc) )
	fi

	myconf+=( $(use_enable qt5) )

	econf "${myconf[@]}"
}

src_compile() {
	emake
	use doc && emake avahi.devhelp
}

src_install() {
	emake install DESTDIR="${D}"
	use bookmarks && use python && use dbus && use gtk2 || \
		rm -f "${ED}"/usr/bin/avahi-bookmarks

	# https://github.com/lathiat/avahi/issues/28
	use howl-compat && dosym avahi-compat-howl.pc /usr/$(get_libdir)/pkgconfig/howl.pc
	use mdnsresponder-compat && dosym avahi-compat-libdns_sd/dns_sd.h /usr/include/dns_sd.h

	if use doc; then
		docinto html
		insinto /usr/share/devhelp/books/avahi
		doins avahi.devhelp
	fi

	# The build system creates an empty "/run" directory, so we clean it up here
	rmdir "${ED}"/run || die
	if use autoipd; then
		insinto /lib/rcscripts/net
		doins "${FILESDIR}"/autoipd.sh

		insinto /lib/netifrc/net
		newins "${FILESDIR}"/autoipd-openrc.sh autoipd.sh
	fi

	dodoc docs/{AUTHORS,NEWS,README,TODO}

	find "${ED}" -name '*.la' -type f -delete || die
}

pkg_postinst() {
	if use autoipd; then
		elog
		elog "To use avahi-autoipd to configure your interfaces with IPv4LL (RFC3927)"
		elog "addresses, just set config_<interface>=( autoipd ) in /etc/conf.d/net!"
		elog
	fi
}