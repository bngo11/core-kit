# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
)

go-module_set_globals

SRC_URI="https://github.com/kubernetes-sigs/kind/tarball/715a5d163739ec398afe8f7361c5e0fc346c83b0 -> kind-0.20.0-715a5d1.tar.gz"

DESCRIPTION="Tool for running local Kubernetes clusters using Docker container nodes"
HOMEPAGE="https://kind.sigs.k8s.io/ https://github.com/kubernetes-sigs/kind"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="hardened"

BDEPEND="dev-lang/go"
RDEPEND="app-emulation/docker"

post_src_unpack() {
	mv "${WORKDIR}"/kubernetes-sigs-kind-* "${S}" || die
}

src_compile() {
	CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')" \
		emake -j1 GOFLAGS="" GOLDFLAGS="" LDFLAGS="" WHAT=cmd/${PN}
}

src_install() {
	dobin bin/${PN}
	dodoc README.md
}