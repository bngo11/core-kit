# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/5b824a493a7ca248b726b6ea09d53842b9b992c2 -> kubernetes-1.36.1-5b824a4.tar.gz
https://direct.funtoo.org/8d/45/95/8d45957407bfeb1fc8f2b9fa5da2bdfc0164d3ffa5c8bcaae578aae9d8a07e68991f4811f7ceb336de7b9e016501905f38b3a42971b749978ee7466d8bbbf804 -> kubectl-1.36.1-funtoo-go-bundle-652d09c518e9a3d4ba665adaad61857e8def6343040eb8eedaac60a44ee9ff061ac08c7849723dfa237712033e8b05c2589a71ab7b283d6005256536cdf9d2d3.tar.gz"

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