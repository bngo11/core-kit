# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517=setuptools

inherit meson python-single-r1

DESCRIPTION="USB enumeration utilities"
HOMEPAGE="https://www.kernel.org/pub/linux/utils/usb/usbutils/
	https://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usbutils.git/"
SRC_URI="https://api.github.com/repos/gregkh/usbutils/tarball/refs/tags/v018 -> usbutils-018.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="virtual/libusb:1=
	virtual/libudev:="
BDEPEND="
	app-arch/xz-utils
	virtual/pkgconfig
	python? ( ${PYTHON_DEPS} )"
RDEPEND="${DEPEND}
	sys-apps/hwids
	python? ( ${PYTHON_DEPS} )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

post_src_unpack() {
	mv ${WORKDIR}/gregkh-usbutils-* ${S} || die
}

src_install() {
	meson_src_install
	newdoc usbhid-dump/NEWS NEWS.usbhid-dump

	if ! use python ; then
		rm -f "${ED}"/usr/bin/lsusb.py || die
	fi
}