# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info meson systemd

DESCRIPTION="Userspace system daemon to enable security levels for Thunderbolt 3"
HOMEPAGE="https://gitlab.freedesktop.org/bolt/bolt"
SRC_URI="https://gitlab.freedesktop.org/bolt/bolt/-/archive/0.9.2/bolt-0.9.2.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="doc systemd"

DEPEND="
	>=dev-libs/glib-2.56.0:2
	dev-util/glib-utils
	virtual/libudev
	virtual/udev
	sys-auth/polkit[introspection]
	systemd? ( sys-apps/systemd )
	doc? ( app-text/asciidoc )"
RDEPEND="${DEPEND}"

pkg_pretend() {
	if use kernel_linux && kernel_is lt 5 6; then
		CONFIG_CHECK="~THUNDERBOLT"
		ERROR_THUNDERBOLT="This package requires the thunderbolt kernel driver."
	else
		CONFIG_CHECK="~USB4"
		ERROR_USB4="This package requires the USB4 kernel driver for Thunderbolt support."
	fi
	check_extra_config

	CONFIG_CHECK="~HOTPLUG_PCI"
	ERROR_HOTPLUG_PCI="Thunderbolt requires PCI hotplug support."
	check_extra_config
}

src_configure() {
	local emesonargs=(
		-Dman=$(usex doc true false)
		--sysconfdir=/etc
		--localstatedir=/var
		--sharedstatedir=/var/lib
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	newinitd "${FILESDIR}"/${PN}.openrc boltd
	keepdir /var/lib/boltd
}