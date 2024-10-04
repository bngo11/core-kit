# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/4190e7226e6c56f2317388e88511f3f73cfbe29c -> kubernetes-1.31.1-4190e72.tar.gz
https://direct.funtoo.org/d9/18/4d/d9184dbdb44ca9134fccb322dc60780503b9cc4c32a3ce510dc98545edb5bd84f56e2e95ab100e91dbc021cef32e67fb580c04fe5f5bb7d872fe8e8f530bf1e6 -> kubectl-1.31.1-funtoo-go-bundle-143668f49e8b58ebd2d69e6d3e44b1f9c3d44dc00241c4dc92b50a0d1b7899a7511a55f2174b0dfed345c1f0a315da40d1abb3056f332387523a0e6abf70711c.tar.gz"

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