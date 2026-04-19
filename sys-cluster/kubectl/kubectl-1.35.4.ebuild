# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/ee674200d315db92e2ef8274bad32731eefe1104 -> kubernetes-1.35.4-ee67420.tar.gz
https://direct.funtoo.org/73/c5/6e/73c56e286e04a3fbaff7255b6b1c17bad7ba3c7b2a9414f23f962ee294042ad2e41b4161ebca795d6c8d731eb5dec4074b29fa500cdfde0d9790256fd1e48840 -> kubectl-1.35.4-funtoo-go-bundle-3b03de307747256d4ceefb81b3a0c900a40f4d246c7f1ee29225a218af279c0aba4abf55656994e991783bea4b70429d89934d5aaf8cd765f1c62dfdd164a794.tar.gz"

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