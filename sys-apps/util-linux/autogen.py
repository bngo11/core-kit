#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	github_user = github_repo = pkginfo.get("name")
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True)
	version = None
	url = None

	for item in json_data:
		try:
			version = item["name"].lstrip("v")
			list(map(int, version.split(".")))
			final_name = f"{github_repo}-{version}.tar.xz"
			url = f"https://mirrors.edge.kernel.org/pub/linux/utils/{github_repo}/v{'.'.join(version.split('.')[:2])}/{final_name}"
			break

		except (KeyError, IndexError, ValueError):
			continue

	if version and url:
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
