# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/49c14f82ca9748897f0189be31cbf9c2f4085fc1 -> kubernetes-1.36.3-49c14f8.tar.gz
https://direct.funtoo.org/1d/9b/35/1d9b352c90c02fef68321c93bdcb3df5ec87318d942d2b60b288b36487a28a61c7262065f591fff79cec41cef523a1690ed1fd4107c7aa4db2d9e68bc3b2bd21 -> kubectl-1.36.3-funtoo-go-bundle-884b08065716e30bca85aea0a834c8d986202d13bdd8e7aa2aa4707995497bf56726e2ca41d7fa782c4fe79a5461fbca46ba3395ea95c49768e7a5aa33362bfb.tar.gz"

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