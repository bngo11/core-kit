# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/5ecab45c278646c9134b656fee70e891da51d0cb -> kubernetes-1.36.2-5ecab45.tar.gz
https://direct.funtoo.org/06/fe/7b/06fe7b5818ac408c1148d5a13495c2c9943ece5d6f66c96527e75f0609394be16067681b5965afbf8ccde2b40330af5cad0f4e00e865efffd4da5d56f34335b3 -> kubectl-1.36.2-funtoo-go-bundle-652d09c518e9a3d4ba665adaad61857e8def6343040eb8eedaac60a44ee9ff061ac08c7849723dfa237712033e8b05c2589a71ab7b283d6005256536cdf9d2d3.tar.gz"

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