# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="manage ssh and GPG keys in a convenient and secure manner. Frontend for ssh-agent/ssh-add"
HOMEPAGE="https://kernel-seeds.org/projects/keychain/"
SRC_URI=" https://github.com/danielrobbins/keychain/releases/download/3.0.8/keychain-3.0.8.pyz -> keychain-3.0.8.pyz "

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""
S="${WORKDIR}"

DEPEND=""
RDEPEND="app-shells/bash || ( net-misc/openssh net-misc/ssh )"

src_unpack() {
	cp ${DISTDIR}/keychain-${PV}.pyz keychain
	default
}

src_install() {
	dobin keychain || die "dobin failed"
}

pkg_postinst() {
	einfo "Please see the keychain man page or visit"
	einfo "$HOMEPAGE"
	einfo "for information on how to use keychain."
}