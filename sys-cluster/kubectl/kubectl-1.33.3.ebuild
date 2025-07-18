# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/70ac69f120c2c5e37c84cba22cdfb62443e20d9a -> kubernetes-1.33.3-70ac69f.tar.gz
https://direct.funtoo.org/76/78/05/767805ee14e696fed20408282cfc1308cd7c7819d4bff33a87d1fa88ad60321163e48f3a79622e457d43c7fa0c784b5f8e7b19f40c1760dc44632c105619333e -> kubectl-1.33.3-funtoo-go-bundle-f4b8bbd52a9e6999bf4f43b086672f9e80e4247d64d39699fa311bfc63ceb2b30f791053a6a354b6af8d04cd9b89a0b1827b333ba16cd3b35d789754d8dfde0b.tar.gz"

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