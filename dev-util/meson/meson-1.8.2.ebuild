# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517=setuptools

inherit bash-completion-r1 distutils-r1 toolchain-funcs

SRC_URI="https://github.com/mesonbuild/meson/tarball/5a82ea0501736a666ca9cc003ea0774f8219fd65 -> meson-1.8.2-5a82ea0.tar.gz"
KEYWORDS="*"

DESCRIPTION="Open source build system"
HOMEPAGE="https://mesonbuild.com/"

LICENSE="Apache-2.0"
SLOT="0"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/mesonbuild-* "${S}"
}

python_install_all() {
	distutils-r1_python_install_all

	insinto /usr/share/vim/vimfiles
	doins -r data/syntax-highlighting/vim/{ftdetect,indent,syntax}
	insinto /usr/share/zsh/site-functions
	doins data/shell-completions/zsh/_meson
}