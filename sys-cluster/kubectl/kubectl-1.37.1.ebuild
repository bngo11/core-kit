# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/d2b770f4c94636a992534a8d3156b6b2d8e82ac3 -> kubernetes-1.37.1-d2b770f.tar.gz
https://direct.funtoo.org/0c/c0/63/0cc063f65b7927239b93e27b03f253b738a0a8f0223eaa2b70280a94abb40f533bda0b2756c88d3b9bcd61f067c467e88bd00d2d9ce96d3195449827926b0013 -> kubectl-1.37.1-funtoo-go-bundle-a229e36b2043dd2e46bc203cda8c376b6754342cf1659577dc6480dcbe947c4fed377a23875ea21b1c27cf909ad1842523bcfda490765258a22d2a20e2d024d8.tar.gz"

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