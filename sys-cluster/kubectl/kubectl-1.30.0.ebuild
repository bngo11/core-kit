# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/11602f083ca275dcfd4341641ae7fe338b7f6f69 -> kubernetes-1.30.0-11602f0.tar.gz
https://direct.funtoo.org/73/d5/a0/73d5a0cc3401e7c35fd1aa7990d781052eb088497ca2790ff2b9225c21cd3eb6631086d87388701bef33aa9a073a99dd02eb5c864adbe1edc6aac5854e98571d -> kubectl-1.30.0-funtoo-go-bundle-e4097fe99bb07c17ceb0fcacff18323e9b75e0230d66ba95226eef08e89a91daa2a13cf2f1861b66d16c53b1aa6078a0ccf4b81ccaf013e689ca541826d3a361.tar.gz"

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