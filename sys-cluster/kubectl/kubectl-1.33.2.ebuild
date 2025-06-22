# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/d43821f9491a55bd544f7c7e894fc97f1eebedd0 -> kubernetes-1.33.2-d43821f.tar.gz
https://direct.funtoo.org/4d/48/97/4d4897b2fa143c1ed84ca24c21e42a0b62bdb115185ed6234a3f15b17b0392747c2f2f599f8ba859e462bff6995d63653072c5b03cb4806e0942fbf43326b49b -> kubectl-1.33.2-funtoo-go-bundle-f4b8bbd52a9e6999bf4f43b086672f9e80e4247d64d39699fa311bfc63ceb2b30f791053a6a354b6af8d04cd9b89a0b1827b333ba16cd3b35d789754d8dfde0b.tar.gz"

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