#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/mirror/ncurses/tags", is_json=True)
	version = None

	for item in json_data:
		try:
			version = item.get("name", '').strip('v')
			list(map(int, version.split(".")))
			break

		except (KeyError, IndexError, ValueError):
			continue

	if version:
		url = f'https://invisible-mirror.net/archives/ncurses/ncurses-{version}.tar.gz'
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=url.rsplit('/', 1)[-1])],
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
