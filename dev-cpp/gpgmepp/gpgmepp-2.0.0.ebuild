# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="GnuPG Made Easy is a library for making GnuPG easier to use (c++ bindings)"
HOMEPAGE="https://www.gnupg.org/related_software/gpgme"
SRC_URI="https://gnupg.org/ftp/gcrypt/gpgmepp/gpgmepp-2.0.0.tar.xz -> gpgmepp-2.0.0.tar.xz"

LICENSE="LGPL-2+ test? ( GPL-2 GPL-2+ LGPL-2.1+ )"
SLOT="0/7"
KEYWORDS="*"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="!<app-crypt/gpgme-2[cxx(-)]
	>=app-crypt/gpgme-${PV%.*}:=
	>=dev-libs/libgpg-error-1.47
"
DEPEND="${RDEPEND}
"

src_configure() {
	local mycmakeargs=(
		# As of 2.0.0, there aren't any non-manual tests. tests/README
		# says that the real testing is done via dev-libs/qgpgme instead.
		-DBUILD_TESTING=$(usex test)
	)

	cmake_src_configure
}