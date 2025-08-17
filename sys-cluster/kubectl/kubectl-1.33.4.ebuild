# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/40e11929472c57793ee75b7a040e81b32cab22a2 -> kubernetes-1.33.4-40e1192.tar.gz
https://direct.funtoo.org/29/6c/e4/296ce433ff7a521940646be5a2af25a6f0716809000397fdcd8fa7d7567686527593a6bd6e575cb6dffc570892349aefe88e403b2ab7dd98f98b916a75e3ea18 -> kubectl-1.33.4-funtoo-go-bundle-f4b8bbd52a9e6999bf4f43b086672f9e80e4247d64d39699fa311bfc63ceb2b30f791053a6a354b6af8d04cd9b89a0b1827b333ba16cd3b35d789754d8dfde0b.tar.gz"

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