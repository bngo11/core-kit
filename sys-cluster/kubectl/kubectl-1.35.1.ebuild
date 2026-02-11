# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/b454787a567812fa492ab0535e3c3ed44189a5bd -> kubernetes-1.35.1-b454787.tar.gz
https://direct.funtoo.org/dd/82/67/dd8267a189825560935fa38fd63edad5f69249e206c82f8f0ecf8cb64df266ab266eef01521c74040eb0e4b6dcec081c566acc9d3fc475798036f1190f918183 -> kubectl-1.35.1-funtoo-go-bundle-c130a50a5d748c86c33649650907fcdbf999a4ab1b70a8ad192115ff5dbb7e0a0fea9ca153597c5221a1c36082b391146b48dcd25f49bc7fb16406d10cfabea5.tar.gz"

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