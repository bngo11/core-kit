#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/relan/exfat/releases", is_json=True)
	version = None
	url = None

	for item in json_data:
		print(pkginfo["name"])
		try:
			if item["prerelease"] or item["draft"]:
				continue

			version = item["tag_name"].strip('v')
			list(map(int, version.split(".")))

			for asset in item['assets']:
				asset_name = asset["name"]
				print(asset_name)
				if asset_name.rsplit('-', 1)[0] != pkginfo["name"]:
					continue

				if asset_name.endswith("tar.gz"):
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
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=asset_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
