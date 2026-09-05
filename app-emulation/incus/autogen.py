#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/lxc/incus/tags", is_json=True)
	version = None
	url = None

	for item in json_data:
		try:
			version = item["name"].strip('v')
			ver_split = version.split(".")
			list(map(int, ver_split))
			if ver_split[-1] == "0":
				version = ".".join(ver_split[:-1])
			break

		except (KeyError, IndexError, ValueError):
			continue

	if version:
		final_name = f"incus-{version}.tar.xz"
		url = f"https://linuxcontainers.org/downloads/incus/{final_name}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
