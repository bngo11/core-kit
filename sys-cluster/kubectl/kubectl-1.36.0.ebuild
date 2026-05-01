# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/02d6d2a6157dd33cb6db3c68c4c6dcb15fd1b3f5 -> kubernetes-1.36.0-02d6d2a.tar.gz
https://direct.funtoo.org/1b/26/b1/1b26b11c26422148e6bf38973fd69c691e7c97dc86024f49d202cd702892f29b926e94eefd1b315e2c826d2be3188f4ea95b09ed746ceed2adc762678924ef99 -> kubectl-1.36.0-funtoo-go-bundle-652d09c518e9a3d4ba665adaad61857e8def6343040eb8eedaac60a44ee9ff061ac08c7849723dfa237712033e8b05c2589a71ab7b283d6005256536cdf9d2d3.tar.gz"

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