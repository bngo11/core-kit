# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 go-module

go-module_set_globals

DESCRIPTION="Define and run multi-container applications with Docker"
HOMEPAGE="https://github.com/docker/compose"
SRC_URI="https://github.com/docker/compose/tarball/8bf0627ea977610b2a5fb234300527ac7bdf2f60 -> compose-2.29.3-8bf0627.tar.gz"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="*"

RDEPEND=">=app-emulation/docker-cli-23.0.0"

RESTRICT="test network-sandbox"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv compose* "${S}" || die
	fi
}

src_prepare() {
	default
	# do not strip
	sed -i -e 's/-s -w//' Makefile || die
}

src_compile() {
	emake VERSION=v${PV}
}

src_test() {
	emake test
}

src_install() {
	exeinto /usr/libexec/docker/cli-plugins
	doexe bin/build/docker-compose
	dodoc README.md
}

pkg_postinst() {
	ewarn
	ewarn "docker-compose 2.x is a sub command of docker"
	ewarn "Use 'docker compose' from the command line instead of"
	ewarn "'docker-compose'"
	ewarn "If you need to keep 1.x around, please run the following"
	ewarn "command before your next --depclean"
	ewarn "# emerge --noreplace docker-compose:0"
}
