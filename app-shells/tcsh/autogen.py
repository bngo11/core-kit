#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	github_user = "tcsh-org"
	github_repo = pkginfo.get("name")
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True)
	version = None
	url = None

	for item in json_data:
		try:
			version = item["name"].lstrip("TCSH").replace("_", ".")
			list(map(int, version.split(".")))
			break

		except (KeyError, IndexError, ValueError):
			continue

	if version:
		final_name = f"{pkginfo.get('name')}-{version}.tar.gz"
		url = f"https://astron.com/pub/tcsh/{final_name}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
