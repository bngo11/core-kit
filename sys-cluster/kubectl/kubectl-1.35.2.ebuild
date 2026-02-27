# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/259cc205cb9dabc4b738a8d76ba385a33b2e8724 -> kubernetes-1.35.2-259cc20.tar.gz
https://direct.funtoo.org/35/88/8c/35888c9fdab17c5e4af3bddf7369bcf4b173e549c264bae5adc3ce62f8fdaa818cfca96e6091e8ffabf9a13e6dfe16b0023b4c45f245abc99b8b242fb19dcc48 -> kubectl-1.35.2-funtoo-go-bundle-c130a50a5d748c86c33649650907fcdbf999a4ab1b70a8ad192115ff5dbb7e0a0fea9ca153597c5221a1c36082b391146b48dcd25f49bc7fb16406d10cfabea5.tar.gz"

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