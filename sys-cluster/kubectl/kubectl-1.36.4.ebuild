# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/b16731bd963a0f0b4ca934ffbd7e56cef33df20e -> kubernetes-1.36.4-b16731b.tar.gz
https://direct.funtoo.org/c0/75/c2/c075c245e5ceb5132a5b3b63e07ab00a1924a41e7c5cc904f69b6d5f8d4735b8275cb6ee4ea6a15039ebc11bc756c923bd1a2121d22a0a4f6bb610d49e77ca69 -> kubectl-1.36.4-funtoo-go-bundle-f98acc650a8b456b3075132c13c15cfe83da499d912d571fe4cb2d34fd4042a18e1e739d0a67b652030277ff18368deee67b6c112c2c5b64bdc06708367fde52.tar.gz"

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