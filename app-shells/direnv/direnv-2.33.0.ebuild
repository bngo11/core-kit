# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
	"github.com/!burnt!sushi/toml v1.3.2"
	"github.com/!burnt!sushi/toml v1.3.2/go.mod"
	"github.com/mattn/go-isatty v0.0.20"
	"github.com/mattn/go-isatty v0.0.20/go.mod"
	"golang.org/x/mod v0.13.0"
	"golang.org/x/mod v0.13.0/go.mod"
	"golang.org/x/sys v0.6.0"
	"golang.org/x/sys v0.6.0/go.mod"
)

go-module_set_globals

DESCRIPTION="Direnv is an environment switcher for the shell"
HOMEPAGE="https://direnv.net"
SRC_URI="https://github.com/direnv/direnv/tarball/9f7e80649301aa10c1a0d5457bfda943e4b40b3a -> direnv-2.33.0-9f7e806.tar.gz
https://direct.funtoo.org/11/43/48/114348734e86b911bad41b1b60c497bc2dc825ce4c5491ec5aa3676a97c7f52837a0482544c5f921fb6189b82453c6510e06178d68cacdf8c0e4bc2f0e714f3c -> direnv-2.33.0-funtoo-go-bundle-e96d6a9bf20d1010b2d2868e86a23b37d616fcec8662f941bf45c16a480eb167bf6be46d4b3758094072c32cbf4928d3ece1e79b329cea1ae4f03cdbbbc38fde.tar.gz"

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