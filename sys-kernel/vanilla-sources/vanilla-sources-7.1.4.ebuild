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

DESCRIPTION="Linux 7.1.4"

SRC_URI="https://mirrors.edge.kernel.org/pub/linux/kernel/v7.x/linux-7.1.tar.xz -> linux-7.1.tar.xz https://mirrors.edge.kernel.org/pub/linux/kernel/v7.x/patch-7.1.4.xz -> patch-7.1.4.xz"

pkg_postinst() {
	kernel-2_pkg_postinst
}

pkg_postrm() {
	kernel-2_pkg_postrm
}