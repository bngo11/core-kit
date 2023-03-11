# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="exFAT filesystem FUSE module"
HOMEPAGE="https://github.com/relan/exfat"
SRC_URI="https://github.com/relan/exfat/releases/download/v1.4.0/fuse-exfat-1.4.0.tar.gz -> fuse-exfat-1.4.0.tar.gz"

# COPYING is GPL-2 but ChangeLog says "Relicensed the project from GPLv3+ to GPLv2+"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="suid"

RDEPEND="sys-fs/fuse:0"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_install() {
	default
	use suid && fperms u+s /usr/sbin/mount.exfat-fuse
	dosym mount.exfat-fuse.8 /usr/share/man/man8/mount.exfat.8
}