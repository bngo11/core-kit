#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/flatpak/libportal/releases", is_json=True)
	version = None

	for item in json_data:
		try:
			if not item["prerelease"]:
				version = item["tag_name"]
				list(map(int, version.split(".")))
				break

		except (IndexError, ValueError, KeyError):
			continue

	if version:
		url = f"https://github.com/flatpak/libportal/releases/download/{version}/libportal-{version}.tar.xz"
		final_name = f"libportal-{version}.tar.xz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)

		ebuild.push()

# vim: ts=4 sw=4 noet
