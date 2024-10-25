# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/d5e17c16ea2fef6527301d994d71ea38e2b11231 -> kubernetes-1.31.2-d5e17c1.tar.gz
https://direct.funtoo.org/c8/d1/2d/c8d12d0515db5dd3201b0339e9be0de447887f476abc98ba5dee3d0df7e93b35cd9057010c7624faddedf0adc283207cb6cc2eb921ee3233ecda40a2974cbf49 -> kubectl-1.31.2-funtoo-go-bundle-143668f49e8b58ebd2d69e6d3e44b1f9c3d44dc00241c4dc92b50a0d1b7899a7511a55f2174b0dfed345c1f0a315da40d1abb3056f332387523a0e6abf70711c.tar.gz"

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