# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/e666bc7de9a51bad471cba21ff41ac9805272281 -> kubernetes-1.35.3-e666bc7.tar.gz
https://direct.funtoo.org/d0/4b/5b/d04b5be10b03b04de44b063fb6c07b161226faabcd29adddd75086e678abab27c2163de44b0d8a0bd5e3406c72dcfe5969d6a58090060a4607aee22b1df9f712 -> kubectl-1.35.3-funtoo-go-bundle-c130a50a5d748c86c33649650907fcdbf999a4ab1b70a8ad192115ff5dbb7e0a0fea9ca153597c5221a1c36082b391146b48dcd25f49bc7fb16406d10cfabea5.tar.gz"

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