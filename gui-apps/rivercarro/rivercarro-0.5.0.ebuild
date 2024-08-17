# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit edo

DESCRIPTION="A slightly modified version of rivertile layout generator for river"
HOMEPAGE="https://git.sr.ht/~novakane/rivercarro"

SRC_URI="
	https://git.sr.ht/~novakane/rivercarro/refs/download/v${PV}/rivercarro-v${PV}.tar.gz -> ${PN}.tar.gz
	https://codeberg.org/ifreund/zig-wayland/archive/v0.2.0.tar.gz -> zig-wayland-0.2.0.tar.gz
"
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

EZIG_MIN="0.13"
EZIG_MAX_EXCLUSIVE="0.14"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="
	|| ( dev-lang/zig-bin:${EZIG_MIN} dev-lang/zig:${EZIG_MIN} )
"

DOCS=( README.md )

# https://github.com/ziglang/zig/issues/3382
QA_FLAGS_IGNORED="usr/bin/*"

# Many thanks to Florian Schmaus (Flowdalic)!
# Adapted from https://github.com/gentoo/gentoo/pull/28986
# Set the EZIG environment variable.
zig-set_EZIG() {
	[[ -n ${EZIG} ]] && return

	local candidate selected selected_ver ver

	for candidate in "${BROOT}"/usr/bin/zig-*; do
		if [[ ! -L ${candidate} || ${candidate} != */zig?(-bin)-+([0-9.]) ]]; then
			continue
		fi

		ver=${candidate##*-}

		if [[ -n ${EZIG_EXACT_VER} ]]; then
			ver_test "${ver}" -ne "${EZIG_EXACT_VER}" && continue

			selected="${candidate}"
			selected_ver="${ver}"
			break
		fi

		if [[ -n ${EZIG_MIN} ]] \
			   && ver_test "${ver}" -lt "${EZIG_MIN}"; then
			# Candidate does not satisfy EZIG_MIN condition.
			continue
		fi

		if [[ -n ${EZIG_MAX_EXCLUSIVE} ]] \
			   && ver_test "${ver}" -ge "${EZIG_MAX_EXCLUSIVE}"; then
			# Candidate does not satisfy EZIG_MAX_EXCLUSIVE condition.
			continue
		fi

		if [[ -n ${selected_ver} ]] \
			   && ver_test "${selected_ver}" -gt "${ver}"; then
			# Candidate is older than the currently selected candidate.
			continue
		fi

		selected="${candidate}"
		selected_ver="${ver}"
	done

	if [[ -z ${selected} ]]; then
		die "Could not find (suitable) zig installation in ${BROOT}/usr/bin"
	fi

	export EZIG="${selected}"
	export EZIG_VER="${selected_ver}"
}

# Invoke zig with the optionally provided arguments.
ezig() {
	zig-set_EZIG

	edo "${EZIG}" "${@}"
}

src_unpack() {
	default

	mkdir "${S}/deps" || die
	ezig fetch --global-cache-dir "${S}/deps" "${DISTDIR}/zig-wayland-0.2.0.tar.gz"
}

src_configure() {
	export ZBS_ARGS=(
		--prefix usr/
		--system "${S}/deps/p"
		-Doptimize=ReleaseSafe
	)
}

src_compile() {
	ezig build "${ZBS_ARGS[@]}"
}

src_test() {
	ezig build test "${ZBS_ARGS[@]}"
}

src_install() {
	DESTDIR="${ED}" ezig build install "${ZBS_ARGS[@]}"

	insinto /usr/share/${PN}
}
