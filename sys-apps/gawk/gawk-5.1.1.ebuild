# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="GNU awk pattern-matching language"
HOMEPAGE="https://www.gnu.org/software/gawk/gawk.html"
SRC_URI="https://ftp.gnu.org/gnu/gawk//gawk-5.1.1.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="next"
IUSE="mpfr nls readline"

RDEPEND="
	dev-libs/gmp:0=
	mpfr? ( dev-libs/mpfr:0= )
	readline? ( sys-libs/readline:0= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-arch/xz-utils
	>=sys-apps/texinfo-6.7
	>=sys-devel/bison-3.4.1
	nls? ( sys-devel/gettext )
"

src_prepare() {
	default

	# use symlinks rather than hardlinks, and disable version links
	sed -i \
		-e '/^LN =/s:=.*:= $(LN_S):' \
		-e '/install-exec-hook:/s|$|\nfoo:|' \
		Makefile.in doc/Makefile.in || die
	sed -i '/^pty1:$/s|$|\n_pty1:|' test/Makefile.in || die #413327
	# fix standards conflict on Solaris
	if [[ ${CHOST} == *-solaris* ]] ; then
		sed -i \
			-e '/\<_XOPEN_SOURCE\>/s/1$/600/' \
			-e '/\<_XOPEN_SOURCE_EXTENDED\>/s/1//' \
			extension/inplace.c || die
	fi
}

src_configure() {
	export ac_cv_libsigsegv=no
	local myeconfargs=(
		--libexec='$(libdir)/misc'
		$(use_with mpfr)
		$(use_enable nls)
		$(use_with readline)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	rm -rf README_d # automatic dodocs barfs
	default

	# Install headers
	insinto /usr/include/awk
	doins *.h
	rm "${ED}"/usr/include/awk/config.h || die
}

pkg_postinst() {
	# symlink creation here as the links do not belong to gawk, but to any awk
	if has_version app-admin/eselect && has_version app-eselect/eselect-awk ; then
		eselect awk update ifunset
	else
		local l
		for l in "${EROOT}"/usr/share/man/man1/gawk.1* "${EROOT}"/usr/bin/gawk ; do
			if [[ -e ${l} ]] && ! [[ -e ${l/gawk/awk} ]] ; then
				ln -s "${l##*/}" "${l/gawk/awk}" || die
			fi
		done
		if ! [[ -e ${EROOT}/bin/awk ]] ; then
			ln -s "../usr/bin/gawk" "${EROOT}/bin/awk" || die
		fi
	fi
}

pkg_postrm() {
	if has_version app-admin/eselect && has_version app-eselect/eselect-awk ; then
		eselect awk update ifunset
	fi
}