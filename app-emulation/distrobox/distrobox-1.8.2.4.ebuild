# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Use any linux distribution inside your terminal. Enable both backward and forward compatibility with software and freedom to use whatever distribution you’re more comfortable with. Mirror available at: https://gitlab.com/89luca89/distrobox"
HOMEPAGE="https://distrobox.privatedns.org/ https://github.com/89luca89/distrobox"
SRC_URI="https://github.com/89luca89/distrobox/tarball/08e4963711ee1c556f8eb44582a3aa0fbb4c9a77 -> distrobox-1.8.2.4-08e4963.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	app-emulation/docker
"
RDEPEND="${DEPEND}"
BDEPEND=""

post_src_unpack() {
	mv "${WORKDIR}"/89luca89-distrobox-* "${S}" || die
}

src_install() {
	mkdir -p "${D}"/usr
	./install -P "${D}"/usr
}