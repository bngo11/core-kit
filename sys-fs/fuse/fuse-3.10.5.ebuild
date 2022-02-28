# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit meson udev python-any-r1

DESCRIPTION="An interface for filesystems implemented in userspace"
HOMEPAGE="https://github.com/libfuse/libfuse"
SRC_URI="https://github.com/libfuse/libfuse/releases/download/${P}/${P}.tar.xz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="3"
KEYWORDS="*"
IUSE="+suid test"
RESTRICT="!test? ( test )"

BDEPEND="virtual/pkgconfig
	test? (
		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-python/pytest[${PYTHON_USEDEP}]')
	)"
RDEPEND=">=sys-fs/fuse-common-3.3.0-r1"

DOCS=( AUTHORS ChangeLog.rst README.md doc/README.NFS doc/kernel.txt )

python_check_deps() {
	has_version -b "dev-python/pytest[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python_setup
}

src_configure() {
	local emesonargs=(
		$(meson_use test examples)
		$(meson_use test tests)
		-Duseroot=false
		-Dudevrulesdir="${EPREFIX}$(get_udevdir)/rules.d"
	)
	meson_src_configure
}

src_test() {
	if [[ ${EUID} != 0 ]]; then
		ewarn "Running as non-root user, skipping tests"
	elif has sandbox ${FEATURES}; then
		ewarn "Sandbox enabled, skipping tests"
	fi
}

src_test() {
	${EPYTHON} -m pytest test || die
}

src_install() {
	meson_src_install

	# installed via fuse-common
	rm -r "${ED}"{/etc,$(get_udevdir)} || die

	# init script location is hard-coded in install_helper.sh
	rm -rf "${D}"/etc || die

	# useroot=false prevents the build system from doing this.
	use suid && fperms u+s /usr/bin/fusermount3

	# manually install man pages to respect compression
	rm -r "${ED}"/usr/share/man || die
	doman doc/{fusermount3.1,mount.fuse3.8}
}
