# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 go-module

go-module_set_globals

DESCRIPTION="Docker CLI plugin for extended build capabilities with BuildKit"
HOMEPAGE="https://github.com/docker/buildx"
SRC_URI="https://github.com/docker/buildx/tarball/257815a6fbaee88976808020bf04274388275ae8 -> buildx-0.17.1-257815a.tar.gz"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="*"

RDEPEND=">=app-emulation/docker-cli-23.0.0"

RESTRICT="test network-sandbox"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv docker-buildx* "${S}" || die
	fi
}

src_prepare() {
	default
	# do not strip
	sed -i -e 's/-s -w//' Makefile || die
}

src_compile() {
	local _buildx_r='github.com/docker/buildx'
	go build -o docker-buildx \
		-ldflags "-linkmode=external
		-X $_buildx_r/version.Version=0.17.1
		-X $_buildx_r/version.Revision=257815a6fbaee88976808020bf04274388275ae8
		-X $_buildx_r/version.Package=$_buildx_r" \
		./cmd/buildx
}

src_test() {
	emake test
}

src_install() {
	exeinto /usr/libexec/docker/cli-plugins
	doexe docker-buildx
	dodoc README.md
}