#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://gitlab.freedesktop.org/api/v4/projects/6840/repository/tags", is_json=True)
	version = None

	for item in json_data:
		try:
			version = item['name']
			list(map(int, version.split(".")))
			break

		except (IndexError, AttributeError, KeyError, ValueError):
			continue

	if version:
		final_name = f"power-profiles-daemon-{version}.tar.gz"
		url = f"https://gitlab.freedesktop.org/hadess/power-profiles-daemon/-/archive/{version}/{final_name}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
