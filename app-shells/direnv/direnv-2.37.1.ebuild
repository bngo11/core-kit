# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
	"github.com/!burnt!sushi/toml v1.5.0"
	"github.com/!burnt!sushi/toml v1.5.0/go.mod"
	"github.com/mattn/go-isatty v0.0.20"
	"github.com/mattn/go-isatty v0.0.20/go.mod"
	"golang.org/x/mod v0.25.0"
	"golang.org/x/mod v0.25.0/go.mod"
	"golang.org/x/sys v0.6.0/go.mod"
	"golang.org/x/sys v0.30.0"
	"golang.org/x/sys v0.30.0/go.mod"
)

go-module_set_globals

DESCRIPTION="Direnv is an environment switcher for the shell"
HOMEPAGE="https://direnv.net"
SRC_URI="https://github.com/direnv/direnv/tarball/7590ee2442104060bb11eedebd7bd6daf3d88fcd -> direnv-2.37.1-7590ee2.tar.gz
https://direct.funtoo.org/3a/04/70/3a047076a519305021e6a8d12d7fdbbd27e7d5c6d828f45406c2445658a5e449db3a5055cfc7dd8bcb0e035c554e588334ee98a5ab2bac17420898a6f92d9659 -> direnv-2.37.1-funtoo-go-bundle-27d9713d36b41c6fe0d1c2c26ac02189d0fb02117b83165370bba94a10c9542ad66fd3c28d1521f153fca5915f567b1f3dd6082a8da1aee03838b910603ad33c.tar.gz"

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