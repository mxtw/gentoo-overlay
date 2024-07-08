EAPI=8

inherit git-r3 go-module

DESCRIPTION="Smart session manager for the terminal"
HOMEPAGE="https://github.com/joshmedeski/sesh"
EGIT_REPO_URI="https://github.com/joshmedeski/sesh.git"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-lang/go-1.21"

src_unpack() {
    git-r3_src_unpack
	go-module_live_vendor
}

src_compile() {
	ego build .
}

src_install() {
	dobin sesh
}

pkg_postinst() {
    elog "sesh has been installed."
}

