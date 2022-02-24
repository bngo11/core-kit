#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/relan/exfat/releases", is_json=True)
	version = None
	url = {}

	for item in json_data:
		try:
			if item["prerelease"] or item["draft"]:
				continue

			version = item["tag_name"].strip('v')
			list(map(int, version.split(".")))

			for asset in item['assets']:
				asset_name = asset["name"]

				if asset_name.endswith("tar.gz"):
					url[asset_name] = asset["browser_download_url"]

			if url:
				break

		except (KeyError, IndexError, ValueError):
			continue

	if version and url:
		for pkgname, dlurl in url.items():
			print(pkgname)
			if pkgname.startswith('exfat-utils'):
				template = "exfat-utils.tmpl"
			else:
				template = "fuse-exfat.tmpl"

			ebuild = hub.pkgtools.ebuild.BreezyBuild(
				name=template.split(".")[0],
				cat="sys-fs",
				version=version,
				template=template,
				artifacts=[hub.pkgtools.ebuild.Artifact(url=dlurl, final_name=pkgname)]
			)
			ebuild.push()

# vim: ts=4 sw=4 noet
