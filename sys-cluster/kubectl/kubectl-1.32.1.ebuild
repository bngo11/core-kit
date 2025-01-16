# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/272016a7c4a71c2e90717cc4e08baa01300ecf4d -> kubernetes-1.32.1-272016a.tar.gz
https://direct.funtoo.org/3d/db/47/3ddb472808207bfe90c9e8c014521bb708b4a418ad6f7f97117c5770fd3bf6ea85c82dcf7ec504c0510212418a61cf241737d1c128350470fc4673efc1f10c2a -> kubectl-1.32.1-funtoo-go-bundle-1e20fe74154df09d45b50d0723a6453a732c7d74c19a38d8d2e6f297990b4999b5759abc26f092f73ee70c4d7126c7505883c99693dc8fb039254582bdf1fd27.tar.gz"

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