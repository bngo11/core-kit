# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
)

go-module_set_globals

DESCRIPTION="a simple but powerful password manager for the terminal"
HOMEPAGE="https://www.gopass.pw/"
SRC_URI="https://github.com/gopasspw/gopass/tarball/44b6af6c901d05183d8361a3cee0c4ad29d83eea -> gopass-1.15.5-44b6af6.tar.gz"

LICENSE="MIT Apache-2.0 BSD MPL-2.0 BSD-2"
SLOT="0"
KEYWORDS="*"

RESTRICT="strip test"

QA_PRESTRIPPED="usr/bin/gopass"

DEPEND="dev-lang/go"
RDEPEND="
	dev-vcs/git
	app-crypt/gnupg
"

post_src_unpack() {
	mv "${WORKDIR}"/gopasspw-gopass-* "${S}" || die
}

src_install() {
	emake install DESTDIR="${ED}/usr"
	einstalldocs
}

pkg_postinst() {
	echo "browser integration app-admin/gopass-jsonapi"
	echo "git credentials helper app-admin/git-credential-gopass"
	echo "haveibeenpwnd.com integration app-admin/gopass-hibp"
	echo "summon secrets helper app-admin/gopass-summon-provider"
}