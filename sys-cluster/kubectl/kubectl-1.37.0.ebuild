# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/157e582fcc3ebba3c22b16721f49d6890f784c1f -> kubernetes-1.37.0-157e582.tar.gz
https://direct.funtoo.org/ab/a4/c0/aba4c00a0dbf8471155a8ebf87549b496029f71b693a8581b4d7b38dcb913c87eb59d35854ba77f8c266e1ce8f8926c5a42dd1d71e34f8962edffdcc5c3a1038 -> kubectl-1.37.0-funtoo-go-bundle-a229e36b2043dd2e46bc203cda8c376b6754342cf1659577dc6480dcbe947c4fed377a23875ea21b1c27cf909ad1842523bcfda490765258a22d2a20e2d024d8.tar.gz"

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