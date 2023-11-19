#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/junegunn/fzf/releases", is_json=True)
	version = None

	for item in json_data:
		try:
			if item["prerelease"] or item["draft"]:
				continue

			version = item["tag_name"]
			list(map(int, version.split(".")))
			break

		except (KeyError, IndexError, ValueError):
			continue

	if version:
		dep_ver = version.split(".")
		dep_ver[-1] = "0"
		dep_ver = ".".join(dep_ver)
		final_name=f'fzf-{version}.tar.gz'
		url=f"https://github.com/junegunn/fzf/archive/{version}.tar.gz"
		depurl=f'https://dev.gentoo.org/~sam/distfiles/app-shells/fzf/fzf-{dep_ver}-deps.tar.xz'
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name),
					hub.pkgtools.ebuild.Artifact(url=depurl)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
