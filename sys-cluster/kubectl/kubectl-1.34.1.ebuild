# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/07c9122556225f4e7f4987f273725e7b0aefaa5a -> kubernetes-1.34.1-07c9122.tar.gz
https://direct.funtoo.org/d1/e0/c0/d1e0c08cba1d42b56fdbeb1ccc6d16521249cd49e72575af0227e7ec2e11ee123554e37497fffac30ec8d63aec7f1cf393404d40346081f788b93ddaee846e83 -> kubectl-1.34.1-funtoo-go-bundle-87b8b86624f2953b77d1f450e4631b754934fca59b825516e163ea2569957691282d67acbdb5028abb89695b19c54d0e3c2d5f9f3c20e4e003e8232fc89788a9.tar.gz"

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