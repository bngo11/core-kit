# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

DESCRIPTION="CLI to run commands against Kubernetes clusters"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/tarball/275918a59a3df182fc5e9f7f9f6e960384399a35 -> kubernetes-1.34.0-275918a.tar.gz
https://direct.funtoo.org/b5/e2/b3/b5e2b3f67e5d578eae3d9a357eb5b7374c54b7acc5de8159fdecfeab1455e78f4b755099f3e7fcc885bf6f39e085aa7fc4fa9016b31c666900f68568b3cbed72 -> kubectl-1.34.0-funtoo-go-bundle-87b8b86624f2953b77d1f450e4631b754934fca59b825516e163ea2569957691282d67acbdb5028abb89695b19c54d0e3c2d5f9f3c20e4e003e8232fc89788a9.tar.gz"

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