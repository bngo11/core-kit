#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/mesonbuild/meson/releases", is_json=True)
	version = None
	url = None

	for item in json_data:
		try:
			if item["prerelease"]:
				continue

			version = item["tag_name"]
			if int(version.split(".")[1]) % 2:
				continue

			for asset in item['assets']:
				asset_name = asset["name"]

				if asset_name.endswith("tar.gz"):
					url = asset["browser_download_url"]
					break

			if url:
				break

		except (IndexError, AttributeError):
			continue

	if version and url:
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=asset_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
