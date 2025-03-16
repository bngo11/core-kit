# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/9bda0764be69f1065fa6543bb38416f2cfbd29d0 -> kubernetes-1.32.3-9bda076.tar.gz
https://direct.funtoo.org/85/e7/f1/85e7f1405ce6e96ec74191829ed6b1d22e021b52ad70e319d35f159080c37840916402dbb160e5ed5a0318f1a4aaee07dcfc41e6504dd1fb3bfc9cc960252a1f -> kubectl-1.32.3-funtoo-go-bundle-0b09881a86ff7f5ceeace8ae5bc77a1e6f83e10b310e45678a11be9b5b07ab380dba45e77b2bc411c44f7351c0a9a9fa39f67a69683ce38a8e82f45ec2ee5487.tar.gz"

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