# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE='bzip2(+),threads(+)'

inherit distutils-r1 linux-info tmpfiles prefix

DESCRIPTION="Portage is the package management and distribution system for Gentoo"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Portage"

LICENSE="GPL-2"
KEYWORDS="*"
SLOT="0"
IUSE="apidoc build doc gentoo-dev +ipc +native-extensions -rsync-verify selinux test xattr"
RESTRICT="!test? ( test )"

BDEPEND="test? ( dev-vcs/git )"
DEPEND="!build? ( $(python_gen_impl_dep 'ssl(+)') )
	>=app-arch/tar-1.27
	dev-lang/python-exec:2
	>=sys-apps/sed-4.0.5 sys-devel/patch
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	apidoc? (
		dev-python/sphinx
		dev-python/sphinx-epytext
	)"
# Require sandbox-2.2 for bug #288863.
# For whirlpool hash, require python[ssl] (bug #425046).
# For compgen, require bash[readline] (bug #445576).
RDEPEND="
	app-arch/zstd
	>=app-arch/tar-1.27
	dev-lang/python-exec:2
	>=sys-apps/findutils-4.4
	!build? (
		>=sys-apps/sed-4.0.5
		app-shells/bash:0[readline]
		>=app-admin/eselect-1.2
		rsync-verify? (
			>=app-crypt/openpgp-keys-gentoo-release-20180706
			>=app-crypt/gnupg-2.2.4-r2[ssl(-)]
		)
	)
	elibc_glibc? ( >=sys-apps/sandbox-2.2 )
	elibc_musl? ( >=sys-apps/sandbox-2.2 )
	elibc_uclibc? ( >=sys-apps/sandbox-2.2 )
	kernel_linux? ( sys-apps/util-linux )
	>=app-misc/pax-utils-0.1.17
	selinux? ( >=sys-libs/libselinux-2.0.94[python,${PYTHON_USEDEP}] )
	xattr? ( kernel_linux? (
		>=sys-apps/install-xattr-0.3
	) )
	!<app-admin/logrotate-3.8.0
	!<app-portage/gentoolkit-0.4.6
	!<app-portage/repoman-2.3.10
	!~app-portage/repoman-3.0.0"
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		userland_GNU? ( >=sys-apps/coreutils-6.4 )
	)
	app-admin/ego"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# NOTE: FEATURES=installsources requires debugedit and rsync

SRC_ARCHIVES="https://dev.gentoo.org/~zmedico/portage/archives"

prefix_src_archives() {
	local x y
	for x in ${@}; do
		for y in ${SRC_ARCHIVES}; do
			echo ${y}/${x}
		done
	done
}

pkg_pretend() {
	local CONFIG_CHECK="~IPC_NS ~PID_NS ~NET_NS ~UTS_NS"
	check_extra_config
}

GITHUB_REPO="$PN"
GITHUB_USER="zmedico"
GITHUB_TAG="261f0f763888d9392927a6cae2af50292fc694a1"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}

PATCHES=(
	"${FILESDIR}/${PN}-2.4.3-remove-gentoo-repos-conf.patch"
	"${FILESDIR}/${PN}-2.3.68-change-global-paths.patch"
	"${FILESDIR}/${PN}-2.3.41-ebuild-nodie.patch"
	"${FILESDIR}/${PN}-2.3.68-set-backtracking-to-6.patch"
	"${FILESDIR}/${PN}-3.0.9-enhanced-metadata.patch"
	"${FILESDIR}/${PN}-2.3.78-static-libs-belong-where-I-put-them.patch"
	"${FILESDIR}/${PN}-2.3.78-module-rebuild.patch"
	"${FILESDIR}/${PN}-3.0.9-add-repodir-variable.patch"
	"${FILESDIR}/${PN}-3.0.14-allow-matches-in-package-updates.patch"
	"${FILESDIR}/${PN}-3.0.14-track-and-deny-keywords-r1.patch"
	"${FILESDIR}/${PN}-3.0.14-aliases-name-check.patch"
	"${FILESDIR}/${PN}-3.0.14-cdn-feature-ignore-mirror.patch"
	"${FILESDIR}/${PN}-3.0.14-fixed_obsolete_egrep_warning.patch"
)

python_prepare_all() {
	distutils-r1_python_prepare_all

	sed -e "s:^VERSION = \"HEAD\"$:VERSION = \"${PV}\":" -i lib/portage/__init__.py || die

	if use native-extensions; then
		printf "[build_ext]\nportage_ext_modules=true\n" >> \
			setup.cfg || die
	fi

	if ! use ipc ; then
		einfo "Disabling ipc..."
		sed -e "s:_enable_ipc_daemon = True:_enable_ipc_daemon = False:" \
			die "failed to patch AbstractEbuildProcess.py"
	fi

	if use xattr && use kernel_linux ; then
		einfo "Adding FEATURES=xattr to make.globals ..."
		echo -e '\nFEATURES="${FEATURES} xattr"' >> cnf/make.globals \
			|| die "failed to append to make.globals"
	fi

	if use build || ! use rsync-verify; then
		sed -e '/^sync-rsync-verify-metamanifest/s|yes|no|' \
			-e '/^sync-webrsync-verify-signature/s|yes|no|' \
			-i cnf/repos.conf || die "sed failed"
	fi

	echo "Enabling direct.funtoo.org..."
	sed -e "s|^GENTOO_MIRRORS=.*$|GENTOO_MIRRORS=https://direct.funtoo.org|" -i cnf/make.globals || die "sed failed"

	if [[ -n ${EPREFIX} ]] ; then
		einfo "Setting portage.const.EPREFIX ..."
		hprefixify -e "s|^(EPREFIX[[:space:]]*=[[:space:]]*\").*|\1${EPREFIX}\"|" \
			-w "/_BINARY/" lib/portage/const.py

		einfo "Prefixing shebangs ..."
		while read -r -d $'\0' ; do
			local shebang=$(head -n1 "$REPLY")
			if [[ ${shebang} == "#!"* && ! ${shebang} == "#!${EPREFIX}/"* ]] ; then
				sed -i -e "1s:.*:#!${EPREFIX}${shebang:2}:" "$REPLY" || \
					die "sed failed"
			fi
		done < <(find . -type f ! -name etc-update -print0)

		einfo "Adjusting make.globals, repos.conf and etc-update ..."
		hprefixify cnf/{make.globals,repos.conf} bin/etc-update

		if use prefix-guest ; then
			sed -e "s|^\(main-repo = \).*|\\1gentoo_prefix|" \
				-e "s|^\\[gentoo\\]|[gentoo_prefix]|" \
				-e "s|^\(sync-uri = \).*|\\1rsync://rsync.prefix.bitzolder.nl/gentoo-portage-prefix|" \
				-i cnf/repos.conf || die "sed failed"
		fi

		einfo "Adding FEATURES=force-prefix to make.globals ..."
		echo -e '\nFEATURES="${FEATURES} force-prefix"' >> cnf/make.globals \
			|| die "failed to append to make.globals"
	fi

	cd "${S}/cnf" || die
	if [ -f "make.conf.example.${ARCH}".diff ]; then
		patch make.conf.example "make.conf.example.${ARCH}".diff || \
			die "Failed to patch make.conf.example"
	else
		eerror ""
		eerror "Portage does not have an arch-specific configuration for this arch."
		eerror "Please notify the arch maintainer about this issue. Using generic."
		eerror ""
	fi
}

python_compile() {
	local DISTUTILS_ARGS=( build )
	use doc && DISTUTILS_ARGS+=( docbook )
	use apidoc && DISTUTILS_ARGS+=( apidoc )

	_distutils-r1_create_setup_cfg

	local setup_py=( setup.py )
	if [[ ! -f setup.py ]]; then
		if [[ ! -f setup.cfg ]]; then
			die "${FUNCNAME}: setup.py nor setup.cfg not found"
		fi
		setup_py=( -c "from setuptools import setup; setup()" )
	fi

	set -- "${EPYTHON}" "${setup_py[@]}" "${DISTUTILS_ARGS[@]}" \
		"${mydistutilsargs[@]}" "${MAKEOPTS}" "${@}"

	echo "${@}" >&2
	"${@}" || die "${die_args[@]}"
}

python_test() {
	esetup.py test
}

python_install() {
	local scriptdir=${EPREFIX}/usr/bin

	# Install sbin scripts to bindir for python-exec linking
	# they will be relocated in pkg_preinst()
	local root=${D%/}/_${EPYTHON}

	# inline DISTUTILS_ARGS logic from esetup.py in order to make
	# argv overwriting easier
	local args=(
		install --skip-build --root="${root}"
		--system-prefix="${EPREFIX}/usr" \
		--bindir="$(python_get_scriptdir)" \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		--portage-bindir="${EPREFIX}/usr/lib/portage/${EPYTHON}" \
		--sbindir="$(python_get_scriptdir)" \
		--sysconfdir="${EPREFIX}/etc" \
	)

	local DISTUTILS_ARGS=()
	local mydistutilsargs=()

	# enable compilation for the install phase.
	local -x PYTHONDONTWRITEBYTECODE=

	# python likes to compile any module it sees, which triggers sandbox
	# failures if some packages haven't compiled their modules yet.
	addpredict "${EPREFIX}/usr/lib/${EPYTHON}"
	addpredict /usr/lib/pypy3.8
	addpredict /usr/lib/portage/pym
	addpredict /usr/local # bug 498232

	merge_root=1

	# user may override --install-scripts
	# note: this is poor but distutils argv parsing is dumb

	# rewrite all the arguments
	set -- "${args[@]}"
	args=()
	echo "params: ${@}"
	while [[ ${@} ]]; do
		local a=${1}
		shift

		case ${a} in
			--install-scripts=*)
				scriptdir=${a#--install-scripts=}
				;;
			--install-scripts)
				scriptdir=${1}
				shift
				;;
			*)
				args+=( "${a}" )
				;;
		esac
	done

	_distutils-r1_create_setup_cfg

	local setup_py=( setup.py )
	if [[ ! -f setup.py ]]; then
		if [[ ! -f setup.cfg ]]; then
			die "${FUNCNAME}: setup.py nor setup.cfg not found"
		fi
		setup_py=( -c "from setuptools import setup; setup()" )
	fi

	set -- "${EPYTHON}" "${setup_py[@]}" "${DISTUTILS_ARGS[@]}" \
		"${args[@]}" "${@}"

	echo "${@}" >&2
	"${@}" || die "${die_args[@]}"

	if [[ ${merge_root} ]]; then
		multibuild_merge_root "${root}" "${D%/}"
	fi
	if [[ ! ${DISTUTILS_SINGLE_IMPL} ]]; then
		_distutils-r1_wrap_scripts "${scriptdir}"
	fi
}

python_install_all() {
	distutils-r1_python_install_all

	local DISTUTILS_ARGS=()
	use doc && DISTUTILS_ARGS+=(
		install_docbook
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html"
	)
	use apidoc && DISTUTILS_ARGS+=(
		install_apidoc
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html"
	)

	# install docs
	if [[ ${DISTUTILS_ARGS[@]} ]]; then
		_distutils-r1_create_setup_cfg

		local setup_py=( setup.py )
		if [[ ! -f setup.py ]]; then
			if [[ ! -f setup.cfg ]]; then
				die "${FUNCNAME}: setup.py nor setup.cfg not found"
			fi
			setup_py=( -c "from setuptools import setup; setup()" )
		fi

		set -- "${EPYTHON}" "${setup_py[@]}" "${DISTUTILS_ARGS[@]}" \
			"${mydistutilsargs[@]}" "${@}"

		echo "${@}" >&2
		"${@}" || die "${die_args[@]}"
	fi

	dotmpfiles "${FILESDIR}"/portage-ccache.conf

	# Due to distutils/python-exec limitations
	# these must be installed to /usr/bin.
	local sbin_relocations='archive-conf dispatch-conf emaint env-update etc-update fixpackages regenworld'
	einfo "Moving admin scripts to the correct directory"
	dodir /usr/sbin
	for target in ${sbin_relocations}; do
		einfo "Moving /usr/bin/${target} to /usr/sbin/${target}"
		mv "${ED}/usr/bin/${target}" "${ED}/usr/sbin/${target}" || die "sbin scripts move failed!"
	done

	# remove webrsync binary that will break Funtoo's meta-repo if accidentally used.
	rm ${ED}/usr/bin/emerge-webrsync || die "rm emerge-webrsync failed"

	# remove glsa binary that doesn't really understand Funtoo's meta-repo and is thus inaccurate
	rm ${ED}/usr/bin/glsa-check || die "rm glsa-check failed"
}

pkg_preinst() {
	python_setup
	local sitedir=$(python_get_sitedir)
	[[ -d ${D}${sitedir} ]] || die "${D}${sitedir}: No such directory"
	env -u DISTDIR \
		-u PORTAGE_OVERRIDE_EPREFIX \
		-u PORTAGE_REPOSITORIES \
		-u PORTDIR \
		-u PORTDIR_OVERLAY \
		PYTHONPATH="${D}${sitedir}${PYTHONPATH:+:${PYTHONPATH}}" \
		"${PYTHON}" -m portage._compat_upgrade.default_locations || die

	env -u BINPKG_COMPRESS \
		PYTHONPATH="${D}${sitedir}${PYTHONPATH:+:${PYTHONPATH}}" \
		"${PYTHON}" -m portage._compat_upgrade.binpkg_compression || die

	# elog dir must exist to avoid logrotate error for bug #415911.
	# This code runs in preinst in order to bypass the mapping of
	# portage:portage to root:root which happens after src_install.
	keepdir /var/log/portage/elog
	# This is allowed to fail if the user/group are invalid for prefix users.
	if chown portage:portage "${ED}"/var/log/portage{,/elog} 2>/dev/null ; then
		chmod g+s,ug+rwx "${ED}"/var/log/portage{,/elog}
	fi

	if has_version "<${CATEGORY}/${PN}-2.3.77"; then
		elog "The emerge --autounmask option is now disabled by default, except for"
		elog "portions of behavior which are controlled by the --autounmask-use and"
		elog "--autounmask-license options. For backward compatibility, previous"
		elog "behavior of --autounmask=y and --autounmask=n is entirely preserved."
		elog "Users can get the old behavior simply by adding --autounmask to the"
		elog "make.conf EMERGE_DEFAULT_OPTS variable. For the rationale for this"
		elog "change, see https://bugs.gentoo.org/658648."
	fi
}

pkg_postinst() {
	echo
	einfo "Fixing permissions on /var/tmp/portage to address CVE-2019-20384."
	einfo "Now, only root, the portage user, and members of the portage group"
	einfo "are permitted to access /var/tmp/portage."
	echo
	chmod o-rwx $ROOT/var/tmp/portage
	echo
	einfo "The 'glsa-check' tool is no longer provided in Funtoo. Use app-admin/vulner instead."
}
