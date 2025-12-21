# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/2049416c7235eeec9a413c38472708e49af3ed88 -> kubernetes-1.35.0-2049416.tar.gz
https://direct.funtoo.org/4e/57/a4/4e57a45ba2ba086432b6c943a72754485d7f83bf4e3c2a463439d474061212e342699b104961f24da36fa8d60b2daae08d1470e2e81349c6202998a52391a9b6 -> kubectl-1.35.0-funtoo-go-bundle-5ec05e1dfbcab612ec4929b9db36f0076bbcd6337c4ab985279f8494d7299bbe09c868b630df0ef23da651189e7c818fc7c25405f4b351ef952a5612f07a91cf.tar.gz"

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