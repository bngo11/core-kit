#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "hpcng"
	github_repo = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True)
	version = None
	url = None

	for release in json_list:
		try:
			if release["prerelease"] or release["draft"] or '-rc' in release['tag_name']:
				continue

			version = release["tag_name"].lstrip("v")
			url = release['assests'][1]['browser_download_url']
			break

		except (IndexError, KeyError, TypeError):
			continue

	if version and url:
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			github_user=github_user,
			github_repo=github_repo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
