# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
	"github.com/!burnt!sushi/toml v1.3.2"
	"github.com/!burnt!sushi/toml v1.3.2/go.mod"
	"github.com/mattn/go-isatty v0.0.20"
	"github.com/mattn/go-isatty v0.0.20/go.mod"
	"golang.org/x/mod v0.15.0"
	"golang.org/x/mod v0.15.0/go.mod"
	"golang.org/x/sys v0.6.0"
	"golang.org/x/sys v0.6.0/go.mod"
)

go-module_set_globals

DESCRIPTION="Direnv is an environment switcher for the shell"
HOMEPAGE="https://direnv.net"
SRC_URI="https://github.com/direnv/direnv/tarball/b2f5e9f205c43670cc948c5ee77a06077a493b2f -> direnv-2.34.0-b2f5e9f.tar.gz
https://direct.funtoo.org/ca/98/7a/ca987a38a1abe442f237f8582241dd91a15aeee60dc6dbd21162ceb967d5992efc417ef183eb0f684d74f51dee77758b09303ec47ae369a61c58a18f1d010d58 -> direnv-2.34.0-funtoo-go-bundle-5b3e48cfcfb02f14732fa1ccd00e493644b79d8dfe8385002cca1e0d079798a2d75d03e7856518c1f813d45731f390f796db10bbdc457687c443f1efd1553aed.tar.gz"

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