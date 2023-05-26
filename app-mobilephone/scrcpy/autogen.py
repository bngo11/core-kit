#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/Genymobile/scrcpy/releases", is_json=True)
	version = None
	server_url = None

	for item in json_data:
		try:
			if item["prerelease"] or item["draft"]:
				continue

			version = item["tag_name"].strip('v')
			list(map(int, version.split(".")))

			for asset in item['assets']:
				asset_name = asset["name"]

				if asset_name.startswith("scrcpy-server"):
					server_url = asset["browser_download_url"]
					break

			if server_url:
				break

		except (KeyError, IndexError, ValueError):
			continue

	if version and server_url:
		url = f'https://github.com/Genymobile/scrcpy/archive/refs/tags/v{version}.tar.gz'
		final_name = f'scrcpy-{version}.tar.gz'
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=server_url),
						hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
