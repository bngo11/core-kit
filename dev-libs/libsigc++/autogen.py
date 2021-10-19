#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/libsigcplusplus/libsigcplusplus/releases", is_json=True)
	version3 = None
	version2 = None

	for item in json_data:
		try:
			if not item['prerelease']:
				vername = item['tag_name']
				if vername.startswith("2") and not version2:
					version2 = vername
					ver2index = ".".join(vername.split('.')[:2])

				if vername.startswith("3") and not version3:
					version3 = vername
					ver3index = ".".join(vername.split('.')[:2])

				if version2 and version3:
					list(map(int, version2.split(".")))
					list(map(int, version3.split(".")))
					break

		except (IndexError, ValueError, KeyError):
			continue

	if version2:
		url = f"https://download.gnome.org/sources/libsigc++/{ver2index}/libsigc++-{version2}.tar.xz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version2,
			template="libsigc++-2.tmpl",
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
		)

		ebuild.push()

	if version3:
		url = f"https://download.gnome.org/sources/libsigc++/{ver3index}/libsigc++-{version3}.tar.xz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version3,
			template="libsigc++-3.tmpl",
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
		)

		ebuild.push()

# vim: ts=4 sw=4 noet
