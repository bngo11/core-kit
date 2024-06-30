# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/c65a738729ac8ba2c7e25cd42d3bbb6f5111116c -> kubernetes-1.30.2-c65a738.tar.gz
https://direct.funtoo.org/eb/4a/e3/eb4ae3ec031e98cba38fcd6b6f96c4d9ad3e2c464046c20cb35f8a4d63cac1395e77af24b0fb505eb3c144345b58d395b25a6755a956aab9f28d44ffb5cc18c3 -> kubectl-1.30.2-funtoo-go-bundle-e4097fe99bb07c17ceb0fcacff18323e9b75e0230d66ba95226eef08e89a91daa2a13cf2f1861b66d16c53b1aa6078a0ccf4b81ccaf013e689ca541826d3a361.tar.gz"

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