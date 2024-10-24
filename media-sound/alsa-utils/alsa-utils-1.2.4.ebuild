# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit systemd udev

DESCRIPTION="Advanced Linux Sound Architecture Utils (alsactl, alsamixer, etc.)"
HOMEPAGE="https://alsa-project.org/"
SRC_URI="https://www.alsa-project.org/files/pub/utils/alsa-utils-1.2.4.tar.bz2"

LICENSE="GPL-2"
SLOT="0.9"
KEYWORDS="*"
IUSE="bat doc +libsamplerate +ncurses nls selinux"

CDEPEND=">=media-libs/alsa-lib-${PV}
	libsamplerate? ( media-libs/libsamplerate )
	ncurses? ( >=sys-libs/ncurses-5.7-r7:0= )
	bat? ( sci-libs/fftw:= )"
DEPEND="${CDEPEND}
	doc? ( app-text/xmlto )"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-alsa )"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	${REPODIR}/media-sound/files/${PN}/${PN}-1.1.8-missing_header.patch
)

src_configure() {
	local myeconfargs=(
		# --disable-alsaconf because it doesn't work with sys-apps/kmod wrt #456214
		--disable-alsaconf
		--disable-maintainer-mode
		--with-asound-state-dir="${EPREFIX}"/var/lib/alsa
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
		--with-udev-rules-dir="${EPREFIX}/$(get_udevdir)"/rules.d
		$(use_enable bat)
		$(use_enable libsamplerate alsaloop)
		$(use_enable ncurses alsamixer)
		$(use_enable nls)
		$(usex doc '' --disable-xmlto)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	dodoc seq/*/README.*

	newinitd ${REPODIR}/media-sound/files/${PN}/alsasound.initd-r8 alsasound
	newconfd ${REPODIR}/media-sound/files/${PN}/alsasound.confd-r4 alsasound

	insinto /etc/modprobe.d
	newins ${REPODIR}/media-sound/files/${PN}/alsa-modules.conf-rc alsa.conf

	keepdir /var/lib/alsa

	# ALSA lib parser.c:1266:(uc_mgr_scan_master_configs) error: could not
	# scan directory /usr/share/alsa/ucm: No such file or directory
	# alsaucm: unable to obtain card list: No such file or directory
	keepdir /usr/share/alsa/ucm
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog
		elog "To take advantage of the init script, and automate the process of"
		elog "saving and restoring sound-card mixer levels you should"
		elog "add alsasound to the boot runlevel. You can do this as"
		elog "root like so:"
		elog "# rc-update add alsasound boot"
		ewarn
		ewarn "The ALSA core should be built into the kernel or loaded through other"
		ewarn "means. There is no longer any modular auto(un)loading in alsa-utils."
	fi
}