# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info meson systemd user

MY_P=${PN}-v${PV}
DESCRIPTION="Realtime Policy and Watchdog Daemon"
HOMEPAGE="https://gitlab.freedesktop.org/pipewire/rtkit"
SRC_URI="https://gitlab.freedesktop.org/pipewire/rtkit/-/archive/v${PV}/${MY_P}.tar.bz2"
S="${WORKDIR}"/${MY_P}

LICENSE="GPL-3 BSD"
SLOT="0"
KEYWORDS="*"
IUSE="selinux systemd"

DEPEND="
	sys-apps/dbus
	sys-auth/polkit
	sys-libs/libcap
	systemd? ( sys-apps/systemd )
"
RDEPEND="
	${DEPEND}
	selinux? ( sec-policy/selinux-rtkit )
"
BDEPEND="
	app-editors/vim-core
	virtual/pkgconfig
"

pkg_pretend() {
	if use kernel_linux; then
		CONFIG_CHECK="~!RT_GROUP_SCHED"
		ERROR_RT_GROUP_SCHED="CONFIG_RT_GROUP_SCHED is enabled. rtkit-daemon (or any other "
		ERROR_RT_GROUP_SCHED+="real-time task) will not work unless run as root. Please consider "
		ERROR_RT_GROUP_SCHED+="unsetting this option."
		check_extra_config
	fi
}

pkg_setup() {
	enewgroup rtkit
	enewuser rtkit -1 -1 -1 rtkit
}

src_configure() {
	local emesonargs=(
		-Dinstalled_tests=false
		$(meson_feature systemd libsystemd)
		-Dsystemd_systemunitdir="$(systemd_get_systemunitdir)"
	)

	meson_src_configure
}
