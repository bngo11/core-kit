# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A simple entropy daemon using the HAVEGE algorithm"
HOMEPAGE="http://www.issihosts.com/haveged/"
#SRC_URI="https://github.com/jirka-h/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="https://github.com/jirka-h/haveged/archive/refs/tags/v1.9.17.tar.gz -> haveged-1.9.17.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="selinux static-libs threads"

RDEPEND="
	!<sys-apps/openrc-0.11.8
	selinux? ( sec-policy/selinux-entropyd )
"

src_configure() {
	local myeconfargs=(
		$(use_enable static-libs static)
		$(use_enable threads)
		--bindir=/usr/sbin
		--enable-nistest
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# Install gentoo ones instead
	newinitd "${FILESDIR}"/haveged-init.d.3 haveged
	newconfd "${FILESDIR}"/haveged-conf.d haveged

	insinto /etc
	doins "${FILESDIR}"/haveged.conf

	find "${ED}" -type f -name "*.la" -delete || die
}