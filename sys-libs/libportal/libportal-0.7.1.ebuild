# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson vala

DESCRIPTION="Flatpak portal library"
HOMEPAGE="https://github.com/flatpak/libportal"
SRC_URI="https://github.com/flatpak/libportal/releases/download/0.7.1/libportal-0.7.1.tar.xz -> libportal-0.7.1.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="gtk gtk-doc +introspection qt5 test +vala"
RESTRICT="!test? ( test )"
REQUIRED_USE="
	gtk-doc? ( introspection )
	vala? ( introspection )
"

RDEPEND="
	>=dev-libs/glib-2.58:2
	introspection? ( dev-libs/gobject-introspection:= )
	gtk? (
		x11-libs/gtk+:3
		gui-libs/gtk:4
	)
	qt5? (
		dev-qt/qtcore:=
		dev-qt/qtgui:=
		dev-qt/qtx11extras:=
		dev-qt/qtwidgets:=
	)
"

DEPEND="${RDEPEND}
	qt5? (
		test? ( dev-qt/qttest:= )
	)
"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? ( dev-util/gi-docgen )
	qt5? (
		test? ( dev-qt/linguist-tools )
	)
	vala? ( $(vala_depend) )
"

src_prepare() {
	default
	vala_src_prepare

}

src_configure() {
	local backends
	use gtk && backends+="gtk3,gtk4,"
	use qt5 && backends+="qt5,"

	local emesonargs=(
		-Dportal-tests=false
		$(meson_feature gtk backend-gtk3)
		$(meson_feature gtk backend-gtk4)
		$(meson_feature qt5 backend-qt5)
		$(meson_use introspection)
		$(meson_use vala vapi)
		$(meson_use gtk-doc docs)
		$(meson_use test tests)
	)

	meson_src_configure
}

src_test() {
	# Tests only exist for Qt5
	if use qt5; then
		virtx meson_src_test
	else
		# run meson_src_test to notice if tests are added
		meson_src_test
	fi
}

src_install() {
	meson_src_install

	if use gtk-doc; then
		mkdir -p "${ED}"/usr/share/gtk-doc/html/ || die
		mv "${ED}"/usr/share/doc/${PN}-1 "${ED}"/usr/share/gtk-doc/html/ || die
	fi
}