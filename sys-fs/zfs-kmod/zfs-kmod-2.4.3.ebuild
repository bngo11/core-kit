# Distributed under the terms of the GNU General Public License v2

EAPI=7

MODULES_INITRAMFS_IUSE=+initramfs
inherit autotools flag-o-matic linux-mod-r1 multiprocessing

DESCRIPTION="Linux ZFS kernel module for sys-fs/zfs"
HOMEPAGE="https://github.com/openzfs/zfs"

MODULES_KERNEL_MAX=6.19
MODULES_KERNEL_MIN=3.10

SRC_URI="https://github.com/openzfs/zfs/tarball/d88276e57da6e80d02a09ddb4c3aa5838be28443 -> zfs-2.4.3-d88276e.tar.gz"
S="${WORKDIR}/zfs-${PV}"

ZFS_KERNEL_COMPAT="${MODULES_KERNEL_MAX}"
# Increments minor eg 5.14 -> 5.15, and still supports override.
ZFS_KERNEL_DEP="${ZFS_KERNEL_COMPAT_OVERRIDE:-${ZFS_KERNEL_COMPAT}}"
ZFS_KERNEL_DEP="${ZFS_KERNEL_DEP%%.*}.$(( ${ZFS_KERNEL_DEP##*.} + 1))"

KEYWORDS="*"

LICENSE="CDDL MIT debug? ( GPL-2+ )"
SLOT="0"
IUSE="custom-cflags debug +rootfs"
RESTRICT="test"

BDEPEND="
	virtual/awk
	dev-lang/perl
"

IUSE+=" +dist-kernel-cap"
RDEPEND="
	dist-kernel-cap? ( dist-kernel? (
		<virtual/dist-kernel-${ZFS_KERNEL_DEP}
	) )
"

# Used to suggest matching USE, but without suggesting to disable
PDEPEND="dist-kernel? ( ~sys-fs/zfs-${PV}[dist-kernel] )"

PATCHES=(
	"${FILESDIR}"/${PN}-2.1.11-gentoo.patch
)

pkg_pretend() {
	use rootfs || return 0
}

pkg_setup() {
	local CONFIG_CHECK="
		EFI_PARTITION
		ZLIB_DEFLATE
		ZLIB_INFLATE
		!DEBUG_LOCK_ALLOC
		!PAX_KERNEXEC_PLUGIN_METHOD_OR
	"
	use debug && CONFIG_CHECK+="
		DEBUG_INFO
		FRAME_POINTER
		!DEBUG_INFO_REDUCED
	"
	use rootfs && CONFIG_CHECK+="
		BLK_DEV_INITRD
		DEVTMPFS
	"

	kernel_is -lt 5 && CONFIG_CHECK+=" IOSCHED_NOOP"

	local kv_major_max kv_minor_max zcompat
	zcompat="${ZFS_KERNEL_COMPAT_OVERRIDE:-${ZFS_KERNEL_COMPAT}}"
	kv_major_max="${zcompat%%.*}"
	zcompat="${zcompat#*.}"
	kv_minor_max="${zcompat%%.*}"
	kernel_is -le "${kv_major_max}" "${kv_minor_max}" || die \
		"Linux ${kv_major_max}.${kv_minor_max} is the latest supported version"

	linux-mod-r1_pkg_setup
}

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		 mv "${WORKDIR}"/* "${S}" || die
	fi
}

src_prepare() {
	default

	# Run unconditionally (bug #792627)
	eautoreconf

	# Set module revision number
	sed -i "s/\(Release:\)\(.*\)1/\1\2${PR}-funtoo/" META || die "Could not set Funtoo release"
}

src_configure() {
	use custom-cflags || strip-flags
	filter-ldflags -Wl,*

	local myconf=(
		--bindir="${EPREFIX}"/bin
		--sbindir="${EPREFIX}"/sbin
		--with-config=kernel
		--with-linux="${KV_DIR}"
		--with-linux-obj="${KV_OUT_DIR}"
		$(use_enable debug)

		# See gentoo.patch
		GENTOO_MAKEARGS_EVAL="${MODULES_MAKEARGS[*]@Q}"
		TEST_JOBS="$(makeopts_jobs)"
	)

	econf "${myconf[@]}"
}

src_compile() {
	emake "${MODULES_MAKEARGS[@]}"
}

src_install() {
	emake "${MODULES_MAKEARGS[@]}" DESTDIR="${ED}" install
	modules_post_process

	dodoc AUTHORS COPYRIGHT META README.md
}

_old_layout_cleanup() {
	# new files are just extra/{spl,zfs}.ko with no subdirs.
	local olddir=(
		avl/zavl
		icp/icp
		lua/zlua
		nvpair/znvpair
		spl/spl
		unicode/zunicode
		zcommon/zcommon
		zfs/zfs
		zstd/zzstd
	)

	# kernel/module/Kconfig contains possible compressed extentions.
	local kext kextfiles
		for kext in .ko{,.{gz,xz,zst}}; do
		kextfiles+=( "${olddir[@]/%/${kext}}" )
	done

	local oldfile oldpath
	for oldfile in "${kextfiles[@]}"; do
		oldpath="${EROOT}/lib/modules/${KV_FULL}/extra/${oldfile}"
		if [[ -f "${oldpath}" ]]; then
			ewarn "Found obsolete zfs module ${oldfile} for current kernel ${KV_FULL}, removing."
			rm -rv "${oldpath}" || die
			# we do not remove non-empty directories just for safety in case there's something else.
			# also it may fail if there are both compressed and uncompressed modules installed.
			rmdir -v --ignore-fail-on-non-empty "${oldpath%/*.*}" || die
		fi
	done
}

pkg_postinst() {
	# Check for old module layout before doing anything else.
	# only attempt layout cleanup if new .ko location is used.
	local newko=( "${EROOT}/lib/modules/${KV_FULL}/extra"/{zfs,spl}.ko* )
	# We check first array member, if glob above did not exand, it will be "zfs.ko*" and -f will return false.
	# if glob expanded -f will do correct file precense check.
	[[ -f ${newko[0]} ]] && _old_layout_cleanup

	linux-mod-r1_pkg_postinst

	if use x86 || use arm ; then
		ewarn "32-bit kernels will likely require increasing vmalloc to"
		ewarn "at least 256M and decreasing zfs_arc_max to some value less than that."
	fi

	if has_version sys-boot/grub ; then
		ewarn "This version of OpenZFS includes support for new feature flags"
		ewarn "that are incompatible with previous versions. GRUB2 support for"
		ewarn "/boot with the new feature flags is not yet available."
		ewarn "Do *NOT* upgrade root pools to use the new feature flags."
		ewarn "Any new pools will be created with the new feature flags by default"
		ewarn "and will not be compatible with older versions of OpenZFS. To"
		ewarn "create a new pool that is backward compatible wih GRUB2, use "
		ewarn
		ewarn "zpool create -o compatibility=grub2 ..."
		ewarn
		ewarn "Refer to /usr/share/zfs/compatibility.d/grub2 for list of features."
	fi
}