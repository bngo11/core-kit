#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/lxc/incus/tags", is_json=True)
	version = None
	url = None

	for item in json_data:
		try:
			version = item["name"].strip('v')
			list(map(int, version.split(".")))
			break

		except (KeyError, IndexError, ValueError):
			continue

	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/lxc/incus/releases", is_json=True)

	for item in json_data:
		try:
			if item["tag_name"].strip('v') != version:
				continue

			for asset in item['assets']:
				asset_name = asset["name"]

				if asset_name.endswith("tar.xz"):
					url = asset["browser_download_url"]
					break

			if url:
				break

		except (KeyError, IndexError, ValueError):
			continue

	if version and url:
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			tar_version=asset_name.split('-')[-1].rsplit('.', 2)[0],
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=asset_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
