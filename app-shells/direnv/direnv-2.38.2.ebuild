# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
	"github.com/!burnt!sushi/toml v1.6.0"
	"github.com/!burnt!sushi/toml v1.6.0/go.mod"
	"github.com/mattn/go-isatty v0.0.24"
	"github.com/mattn/go-isatty v0.0.24/go.mod"
	"golang.org/x/mod v0.41.0"
	"golang.org/x/mod v0.41.0/go.mod"
	"golang.org/x/sys v0.48.0"
	"golang.org/x/sys v0.48.0/go.mod"
)

go-module_set_globals

DESCRIPTION="Direnv is an environment switcher for the shell"
HOMEPAGE="https://direnv.net"
SRC_URI="https://github.com/direnv/direnv/tarball/28a73d1df3f387e16f3c7fa888c2a049e0059e7a -> direnv-2.38.2-28a73d1.tar.gz
https://direct.funtoo.org/86/2f/cb/862fcbf7d7e11ad90e2dd58dc8072188bd226ac3fb8de54dac6381df3e6a5511d2ffeae6a9bfc40e1b0f75e5ad7455b2b3f34c5d57039be6af8aa4e8412cfca2 -> direnv-2.38.2-funtoo-go-bundle-8c7354565fe1c67bcd39e38bc4edc264c4de6a26c83f26ef3618bc0b9254b1c67598ec2f2407745a5bb45b846131c51e9b6a98c621bf89dc8edfd8d2cc65c1ff.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-lang/go"

# depends on golangci-lint which we do not have an ebuild for
RESTRICT="test"

post_src_unpack() {
	mv "${WORKDIR}"/direnv-direnv-* "${S}" || die
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install
	einstalldocs
}