# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit python-single-r1 xdg-utils

DESCRIPTION="A library for manipulating block devices"
HOMEPAGE="https://github.com/storaged-project/libblockdev"

MY_PV="${PV}-1"
SRC_URI="https://github.com/storaged-project/libblockdev/releases/download/3.0-1/libblockdev-3.0.tar.gz -> libblockdev-3.0.tar.gz"
KEYWORDS="*"

LICENSE="LGPL-2+"
SLOT="0"
IUSE="bcache +cryptsetup device-mapper dmraid escrow gtk-doc introspection lvm kbd test +tools vdo"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.64.2
	dev-libs/libbytesize
	>=sys-apps/kmod-26
	>=sys-apps/util-linux-2.34
	>=sys-block/parted-3.2
	cryptsetup? (
		escrow? (
			>=dev-libs/nss-3.49
			dev-libs/volume_key
		)
		>=sys-fs/cryptsetup-2.2.0:=
	)
	device-mapper? ( sys-fs/lvm2 )
	dmraid? (
		sys-fs/dmraid
		sys-fs/lvm2
	)
	lvm? (
		sys-fs/lvm2
		virtual/udev
	)
	vdo? ( dev-libs/libyaml )
	${PYTHON_DEPS}
"

DEPEND="
	${RDEPEND}
"

BDEPEND+="
	dev-util/gtk-doc-am
	gtk-doc? ( dev-util/gtk-doc )
	introspection? ( >=dev-libs/gobject-introspection-1.64.1 )
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
		escrow? ( cryptsetup )"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	xdg_environment_reset #623992
	default
	[[ "${PV}" == *9999 ]] && eautoreconf
}

src_configure() {
	local myeconfargs=(
		--with-btrfs
		--with-fs
		--with-part
		--without-mpath
		--without-nvdimm
		$(use_enable introspection)
		$(use_enable test tests)
		$(use_with bcache)
		$(use_with cryptsetup crypto)
		$(use_with device-mapper dm)
		$(use_with dmraid)
		$(use_with escrow)
		$(use_with gtk-doc)
		$(use_with kbd)
		$(use_with lvm lvm)
		$(use_with lvm lvm-dbus)
		$(use_with tools)
		$(use_with vdo)
	)
	if python_is_python3 ; then
		myeconfargs+=(
			--without-python2
			--with-python3
		)
	else
		myeconfargs+=(
			--with-python2
			--without-python3
		)
	fi
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
	# This is installed even with USE=-lvm, but libbd_lvm are omitted so it
	# doesn't work at all.
	if ! use lvm; then
		rm -f "${ED}"/usr/bin/lvm-cache-stats || die
	fi
	python_optimize #718576
}