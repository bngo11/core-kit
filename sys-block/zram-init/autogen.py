#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	github_user = "vaeth"
	github_repo = pkginfo.get("name")
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True)
	version = None
	url = None

	for item in json_data:
		try:
			if item["prerelease"] or item["draft"]:
				continue

			version = item["tag_name"].lstrip("v")
			list(map(int, version.split(".")))
			url = item["tarball_url"]
			break

		except (KeyError, IndexError, ValueError):
			continue

	if version and url:
		final_name = f"{github_repo}-{version}.tar.gz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
