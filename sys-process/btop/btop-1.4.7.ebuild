# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs xdg-utils

DESCRIPTION="A monitor of resources"
HOMEPAGE="https://github.com/aristocratos/btop"
SRC_URI="https://github.com/aristocratos/btop/tarball/d43a485ef69eca4da321dcec4f4806a38460ef78 -> btop-1.4.7-d43a485.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/aristocratos-btop-d43a485"

src_prepare() {
	default

	# btop installs README.md to /usr/share/btop by default
	sed -i '/^.*cp -p README.md.*$/d' Makefile || die
}

src_compile() {
	# Disable btop optimization flags, since we have our flags in CXXFLAGS
	emake VERBOSE=true OPTFLAGS="" CXX="$(tc-getCXX)"
}

src_install() {
	emake \
		PREFIX="${EPREFIX}/usr" \
		DESTDIR="${D}" \
		install

	dodoc README.md CHANGELOG.md
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}