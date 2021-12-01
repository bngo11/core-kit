# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="userspace RCU (read-copy-update) library"
HOMEPAGE="https://liburcu.org/"
SRC_URI="https://lttng.org/files/urcu/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0/8" # subslot = soname version
KEYWORDS="*"
IUSE="static-libs regression-test test"
RESTRICT="!test? ( test )"

DEPEND="test? ( sys-process/time )"

src_configure() {
	local myeconfargs=(
		--enable-shared
		$(use_enable static-libs static)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}

src_test() {
	default
	if use regression-test ; then
		emake -C tests/regression regtest
	fi
}
