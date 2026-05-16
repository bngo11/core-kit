# Distributed under the terms of the GNU General Public License v2

EAPI="6"
ETYPE="sources"
KEYWORDS="*"

HOMEPAGE="http://kernel.org/"

K_SECURITY_UNSUPPORTED="1"

inherit kernel-2
detect_version
detect_arch

RDEPEND="virtual/linux-sources"

DESCRIPTION="Linux 7.0.8"

SRC_URI="https://mirrors.edge.kernel.org/pub/linux/kernel/v7.x/linux-7.0.tar.xz -> linux-7.0.tar.xz https://mirrors.edge.kernel.org/pub/linux/kernel/v7.x/patch-7.0.8.xz -> patch-7.0.8.xz"

pkg_postinst() {
	kernel-2_pkg_postinst
}

pkg_postrm() {
	kernel-2_pkg_postrm
}