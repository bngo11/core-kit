# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit meson python-any-r1

SRC_URI="https://gitlab.freedesktop.org/hadess/power-profiles-daemon/-/archive/0.23/power-profiles-daemon-0.23.tar.gz -> power-profiles-daemon-0.23.tar.gz"
KEYWORDS="*"

DESCRIPTION="Makes power profiles handling available over D-Bus."
HOMEPAGE="https://gitlab.freedesktop.org/hadess/power-profiles-daemon"

LICENSE="GPL-3+"
SLOT="0"

IUSE="doc pylint tests"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-libs/libgudev-237
	>=sys-auth/polkit-0.120[introspection]
	>=dev-python/shtab-1.7
	>=dev-python/pygobject-3.48:3
"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.33 )
"

src_configure() {
	local emesonargs=(
		-Dsystemdsystemunitdir=/usr/lib/systemd/user/
		$(meson_use doc gtk_doc)
		$(meson_feature pylint)
		$(meson_use tests)
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	newinitd "${FILESDIR}/power-profiles-daemon" power-profiles-daemon
}