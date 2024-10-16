# Distributed under the terms of the GNU General Public License v2
# Robin H. Johnson <robbat2@gentoo.org>, 12 Nov 2007:
# This still needs major work.
# But it is significently better than the previous version.
# In that it will now build on biarch systems, such as ppc64-32ul.

# NOTES:
# ======
# We need to bring in the kernel sources seperately
# Because they have to be configured in a way that differs from the copy in
# /usr/src/. The sys-kernel/linux-headers are too stripped down to use
# unfortunately.

EAPI=7

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="A minimal libc subset for use with initramfs"
HOMEPAGE="http://www.zytor.com/mailman/listinfo/klibc/ https://www.kernel.org/pub/linux/libs/klibc/"
SRC_URI="https://git.kernel.org/pub/scm/libs/klibc/klibc.git/snapshot/klibc-2.0.10.tar.gz https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.16.tar.xz"

LICENSE="|| ( GPL-2 LGPL-2 )"
KEYWORDS="*"
SLOT="0"
IUSE="debug test custom-cflags"

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}"

KS="${WORKDIR}/linux-5.16"

# Klibc has no PT_GNU_STACK support, so scanning for execstacks is moot
QA_EXECSTACK="*"
# Do not strip
RESTRICT="strip"

kernel_asm_arch() {
	a="${1:${ARCH}}"
	case ${a} in
		# Merged arches
		x86) echo i386 ;; # for build on x86 userspace & 64bit kernel
		amd64) echo x86 ;;
		ppc*) echo powerpc ;;
		# Non-merged
		alpha|arm|arm64|ia64|m68k|mips|sh|sparc*) echo ${1} ;;
		*) die "TODO: Update the code for your asm-ARCH symlink" ;;
	esac
}

# For a given ARCH,
# specify the kernel defconfig most relevant
kernel_defconfig() {
	a="${1:${ARCH}}"
	# most, but not all arches have a sanely named defconfig
	case ${a} in
		ppc64) echo ppc64_defconfig ;;
		ppc) echo pmac32_defconfig ;;
		sh*) die "TODO: Your arch is not supported by the klibc ebuild. Please suggest a defconfig in a bug." ;;
		*) echo defconfig ;;
	esac
}

PATCHES=(
	# Build interp.o with EXTRA_KLIBCAFLAGS (.S source)
	"${FILESDIR}"/${PN}-1.4.11-interp-flags.patch
	# The inline definition from sys/stat.h does not seem to get used
	# So just copy it to make this compile for now
	"${FILESDIR}"/klibc-2.0.2-mkfifo.patch
)

src_prepare() {
	# Symlink /usr to ${S}/linux
	ln -snf "${KS}/usr" linux

	default
}

# klibc has it's own ideas of arches
# They reflect userspace strictly.
# This functions maps from a Gentoo ARCH, to an arch that klibc expects
# Look at klibc-${S}/usr/klibc/arch for a list of these arches
klibc_arch() {
	a="${1:${ARCH}}"
	case ${a} in
		amd64) echo x86_64;;
		mips) die 'TODO: Use the $ABI' ;;
		x86) echo i386;;
		*) echo ${a} ;;
	esac
}

src_compile() {
	local myargs="all"
	local myARCH="${ARCH}" myABI="${ABI}"
	# TODO: For cross-compiling
	# You should set ARCH and ABI here
	CC="$(tc-getCC)"
	LD="$(tc-getLD)"
	HOSTCC="$(tc-getBUILD_CC)"
	HOSTLD="$(tc-getBUILD_LD)"
	KLIBCARCH="$(klibc_arch ${ARCH})"
	KLIBCASMARCH="$(kernel_asm_arch ${ARCH})"
	libdir="$(get_libdir)"
	# This should be the defconfig corresponding to your userspace!
	# NOT your kernel. PPC64-32ul would choose 'ppc' for example.
	defconfig=$(kernel_defconfig ${ARCH})
	unset ABI ARCH # Unset these, because they interfere
	unset KBUILD_OUTPUT # we are using a private copy

	cd "${KS}"
	emake ${defconfig} CC="${CC}" HOSTCC="${HOSTCC}" ARCH="${KLIBCASMARCH}" || die "No defconfig"
	if [[ "${KLIBCARCH/arm}" != "${KLIBCARCH}" ]] && \
	   [[ "${CHOST/eabi}" != "${CHOST}" ]]; then
		# The delete and insert are seperate statements
		# so that they are reliably used.
		sed -i \
		-e '/CONFIG_AEABI/d' \
		-e '1iCONFIG_AEABI=y' \
		-e '/CONFIG_OABI_COMPAT/d' \
		-e '1iCONFIG_OABI_COMPAT=y' \
		-e '1iCONFIG_ARM_UNWIND=y' \
		"${KS}"/.config \
		"${S}"/defconfig
	fi
	emake headers_install CC="${CC}" HOSTCC="${HOSTCC}" ARCH="${KLIBCASMARCH}" || die "Failed to install kernel headers"

	cd "${S}"

	use debug && myargs="${myargs} V=1"
	use test && myargs="${myargs} test"
	append-ldflags -z noexecstack
	append-flags -nostdlib
	append-flags -fno-pie
	emake \
		EXTRA_KLIBCAFLAGS="-Wa,--noexecstack" \
		EXTRA_KLIBCLDFLAGS="-z noexecstack" \
		HOSTLDFLAGS="-z noexecstack" \
		KLIBCOPTFLAGS='-nostdlib' \
		HOSTCC="${HOSTCC}" CC="${CC}" \
		HOSTLD="${HOSTLD}" LD="${LD}" \
		INSTALLDIR="/usr/$(get_libdir)/klibc" \
		KLIBCARCH=${KLIBCARCH} \
		KLIBCASMARCH=${KLIBCASMARCH} \
		SHLIBDIR="/$(get_libdir)" \
		libdir="/usr/$(get_libdir)" \
		mandir="/usr/share/man" \
		T="${T}" \
		$(use custom-cflags || echo SKIP_)HOSTCFLAGS="${CFLAGS}" \
		$(use custom-cflags || echo SKIP_)HOSTLDFLAGS="${LDFLAGS}" \
		$(use custom-cflags || echo SKIP_)KLIBCOPTFLAGS="${CFLAGS}" \
		${myargs} || die "Compile failed!"

	ARCH="${myARCH}" ABI="${myABI}"
}

src_install() {
	local myargs
	local myARCH="${ARCH}" myABI="${ABI}"
	# TODO: For cross-compiling
	# You should set ARCH and ABI here
	CC="$(tc-getCC)"
	HOSTCC="$(tc-getBUILD_CC)"
	KLIBCARCH="$(klibc_arch ${ARCH})"
	KLIBCASMARCH="$(kernel_asm_arch ${ARCH})"
	libdir="$(get_libdir)"
	# This should be the defconfig corresponding to your userspace!
	# NOT your kernel. PPC64-32ul would choose 'ppc' for example.
	defconfig=$(kernel_defconfig ${ARCH})

	use debug && myargs="${myargs} V=1"

	local klibc_prefix
	if tc-is-cross-compiler ; then
		klibc_prefix=$("${S}/klcc/${KLIBCARCH}-klcc" -print-klibc-prefix)
	else
		klibc_prefix=$("${S}/klcc/klcc" -print-klibc-prefix)
	fi

	unset ABI ARCH # Unset these, because they interfere
	unset KBUILD_OUTPUT # we are using a private copy

	emake \
		EXTRA_KLIBCAFLAGS="-Wa,--noexecstack" \
		EXTRA_KLIBCLDFLAGS="-z noexecstack" \
		HOSTLDFLAGS="-z noexecstack" \
		KLIBCOPTFLAGS='-nostdlib' \
		HOSTCC="${HOSTCC}" CC="${CC}" \
		HOSTLD="${HOSTLD}" LD="${LD}" \
		INSTALLDIR="/usr/$(get_libdir)/klibc" \
		INSTALLROOT="${D}" \
		KLIBCARCH=${KLIBCARCH} \
		KLIBCASMARCH=${KLIBCASMARCH} \
		SHLIBDIR="/$(get_libdir)" \
		libdir="/usr/$(get_libdir)" \
		mandir="/usr/share/man" \
		T="${T}" \
		$(use custom-cflags || echo SKIP_)HOSTCFLAGS="${CFLAGS}" \
		$(use custom-cflags || echo SKIP_)HOSTLDFLAGS="${LDFLAGS}" \
		$(use custom-cflags || echo SKIP_)KLIBCOPTFLAGS="${CFLAGS}" \
		${myargs} \
		install || die "Install failed!"

	# klibc doesn't support prelinking, so we need to mask it
	cat > "${T}/70klibc" <<-EOF
		PRELINK_PATH_MASK="/usr/$(get_libdir)/klibc"
	EOF

	doenvd "${T}"/70klibc

	# Fix the permissions (bug #178053) on /usr/$(get_libdir)/klibc/include
	# Actually I have no idea, why the includes have those weird-ass permissions
	# on a particular system, might be due to inherited permissions from parent
	# directory
	# NOTE: This totally violates sandbox <asturm@gentoo.org>
	# find "${D}"/usr/$(get_libdir)/klibc/include | xargs chmod o+rX
	find "${D}"/usr/$(get_libdir)/klibc/include -type f \
		\( -name '.install' -o -name '..install.cmd' \) -delete || die

	# Hardlinks becoming copies
	for x in gunzip zcat ; do
		rm -f "${D}/${klibc_prefix}/bin/${x}"
		dosym gzip "${klibc_prefix}/bin/${x}"
	done

	# Restore now, so we can use the tc- functions
	ARCH="${myARCH}" ABI="${myABI}"
	if ! tc-is-cross-compiler ; then
		cd "${S}"
		insinto /usr/share/aclocal
		doins contrib/klibc.m4

		dodoc README usr/klibc/CAVEATS
		docinto gzip; dodoc usr/gzip/README
	fi

	# Fix up the symlink
	# Mainly for merged arches
	linkname="${D}/usr/$(get_libdir)/klibc/include/asm"
	if [ -L "${linkname}" ] && [ ! -e "${linkname}" ] ; then
		ln -snf asm-${KLIBCASMARCH} "${linkname}"
	fi
}

src_test() {
	if ! tc-is-cross-compiler ; then
		cd "${S}"/usr/klibc/tests
		ALL_TESTS="$(ls *.c |sed 's,\.c$,,g')"
		BROKEN_TESTS="fcntl fnmatch testrand48"
		failed=0
		for t in $ALL_TESTS ; do
			if has $t $BROKEN_TESTS ; then
				echo "=== $t SKIP"
			else
				echo -n "=== $t "
				./$t </dev/null >/dev/null
				rc=$?
				if [ $rc -eq 0 ]; then
					echo PASS
				else
					echo FAIL
					failed=1
				fi
			fi
		done
		[ $failed -ne 0 ] && die "Some tests failed."
	fi
}