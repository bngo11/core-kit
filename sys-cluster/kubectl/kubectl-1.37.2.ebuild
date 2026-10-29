# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/1755f07c19a1d4a25955616aabdfdd66e0fbe224 -> kubernetes-1.37.2-1755f07.tar.gz
https://direct.funtoo.org/f8/5f/63/f85f6325ed4661d871d2ee701e685701a7a214c221d5451abbd3715a64953a7af8e805588b2d933127c93aa89f52afdb04e0198f51802dfd6681820e3cd878b2 -> kubectl-1.37.2-funtoo-go-bundle-a229e36b2043dd2e46bc203cda8c376b6754342cf1659577dc6480dcbe947c4fed377a23875ea21b1c27cf909ad1842523bcfda490765258a22d2a20e2d024d8.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="hardened"

DEPEND="!sys-cluster/kubernetes"
BDEPEND=">=dev-lang/go-1.21"

RESTRICT+=" test"

src_unpack() {
	default
	rm -rf ${S}
	mv ${WORKDIR}/kubernetes-kubernetes-* ${S} || die
}

src_compile() {
	CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')" \
	FORCE_HOST_GO=yes \
		emake -j1 GOFLAGS="" GOLDFLAGS="" LDFLAGS="" WHAT=cmd/${PN}
}

src_install() {
	dobin _output/bin/${PN}
	_output/bin/${PN} completion bash > ${PN}.bash || die
	_output/bin/${PN} completion zsh > ${PN}.zsh || die
	newbashcomp ${PN}.bash ${PN}
	insinto /usr/share/zsh/site-functions
	newins ${PN}.zsh _${PN}
}