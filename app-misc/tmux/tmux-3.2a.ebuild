# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic

DESCRIPTION="Terminal multiplexer"
HOMEPAGE="https://tmux.github.io/"
SRC_URI="https://github.com/tmux/tmux/releases/download/3.2a/tmux-3.2a.tar.gz"
KEYWORDS="*"
S="${WORKDIR}/${P/_/-}"

LICENSE="ISC"
SLOT="0"
IUSE="debug selinux utempter vim-syntax kernel_linux"

DEPEND="
	dev-libs/libevent:0=
	sys-libs/ncurses:0=
	utempter? ( sys-libs/libutempter )
"

BDEPEND="
	virtual/pkgconfig
	virtual/yacc
"

RDEPEND="
	${DEPEND}
	selinux? ( sec-policy/selinux-screen )
	vim-syntax? ( app-vim/vim-tmux )"

DOCS=( CHANGES README )

PATCHES=(
	"${FILESDIR}/${PN}-2.4-flags.patch"

	# upstream fixes (can be removed with next version bump)
)

src_prepare() {
	# bug 438558
	# 1.7 segfaults when entering copy mode if compiled with -Os
	replace-flags -Os -O2

	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--sysconfdir="${EPREFIX}"/etc
		$(use_enable debug)
		$(use_enable utempter)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	einstalldocs

	dodoc example_tmux.conf
	docompress -x /usr/share/doc/${PF}/example_tmux.conf
}