# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_SETUPTOOLS=no
PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="xml"

inherit distutils-r1

DESCRIPTION="Searchable online file/package database for Gentoo"
HOMEPAGE="http://www.portagefilelist.de https://github.com/portagefilelist/client"
SRC_URI="https://api.github.com/repos/portagefilelist/client/tarball/3.2 -> pfl-3.2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="+network-cron"

DEPEND=""
RDEPEND="
	${DEPEND}
	dev-python/requests[${PYTHON_USEDEP}]
	net-misc/curl
	sys-apps/portage[${PYTHON_USEDEP}]
	network-cron? ( sys-apps/util-linux[caps] )
"

src_unpack() {
	default
	rm -rf "${S}"
	mv "${WORKDIR}"/portagefilelist-client-* "${S}"
}

python_install_all() {
	if use network-cron ; then
		exeinto /etc/cron.weekly
		doexe cron/pfl
	fi

	keepdir /var/lib/${PN}
	distutils-r1_python_install_all
}

pkg_postinst() {
	if [[ ! -e "${EROOT}/var/lib/${PN}/pfl.info" ]]; then
		touch "${EROOT}/var/lib/${PN}/pfl.info" || die
	fi
	chown -R portage:portage "${EROOT}/var/lib/${PN}" || die
	chmod 775 "${EROOT}/var/lib/${PN}" || die
}