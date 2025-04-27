# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/a42c4d251150d33c4b15cb8aef3759d7599551e6 -> kubernetes-1.33.0-a42c4d2.tar.gz
https://direct.funtoo.org/5f/53/b5/5f53b5b42d3276e2a80522935b45628f014c24f88ed1245be63978995118cc3a567dc62560e5d87a2f65613b23e09bff49900df81c37469e1bacee5ff1b66a02 -> kubectl-1.33.0-funtoo-go-bundle-6d80ab83d4b29f8cd2cb34b1559aee2366d2045f27c2488d031911868c8c5ab13f9589ccbd879ed64577dd305bbe9eb90b43aedb5dc476afa1bb6ec4e431de7c.tar.gz"

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