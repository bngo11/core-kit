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
SRC_URI="https://github.com/direnv/direnv/tarball/e24ea74873aff78d5e371c85061dc7fafdeedd5a -> direnv-2.38.1-e24ea74.tar.gz
https://direct.funtoo.org/29/f0/af/29f0af08fac5add77f9bc783d60c385d8ae5e5992a3d15b4471ac35f440dce060d7a0e07aaa58131a919f297628d6ae0d7055dbdafd1242794545f185877c6c0 -> direnv-2.38.1-funtoo-go-bundle-8c7354565fe1c67bcd39e38bc4edc264c4de6a26c83f26ef3618bc0b9254b1c67598ec2f2407745a5bb45b846131c51e9b6a98c621bf89dc8edfd8d2cc65c1ff.tar.gz"

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