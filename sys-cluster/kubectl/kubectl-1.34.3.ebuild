# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/83121daffb5bc787717b1eeed83b6feb4b58b0d5 -> kubernetes-1.34.3-83121da.tar.gz
https://direct.funtoo.org/74/e3/66/74e3663c9bad03a5ddf29caa41d371a7162fb7fc88762c1733762ec5f5a644f9a1ce3aceaedac9e13a75c1404f2844d4c24ce40447181019887fcc064d3fad13 -> kubectl-1.34.3-funtoo-go-bundle-bc45735b994843179313403adfa4f513669f94b20f8a72e3514295b3ab8a0bec51b5fa699ad0c8f93f98090963c71dda679ccf39b7f9a0ec80322543a11b0ceb.tar.gz"

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