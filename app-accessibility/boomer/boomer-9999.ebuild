EAPI=8

inherit git-r3

DESCRIPTION="Zoomer application for Linux"
HOMEPAGE="https://github.com/tsoding/boomer"
EGIT_REPO_URI="https://github.com/tsoding/boomer.git"
LICENSE="MIT"
SLOT="0"
IUSE=""

# TODO: figure out versions to use
DEPEND="
	dev-lang/nim
	x11-libs/libX11
	media-libs/mesa
	x11-libs/libXext
	x11-libs/libXrandr
"

RESTRICT="network-sandbox"

src_unpack() {
    git-r3_src_unpack
}

src_compile() {
	nimble build -y
}

src_install() {
	dobin boomer
}

pkg_postinst() {
    elog "boomer has been installed."
}

