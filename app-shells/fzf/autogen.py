#!/usr/bin/env python3

import json
from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	html_data = await hub.pkgtools.fetch.get_page("https://dev.gentoo.org/~sam/distfiles/app-shells/fzf/")
	soup = BeautifulSoup(html_data, "html.parser")
	links = soup.find_all("a")
	links.reverse()
	deps_ver = links[0].get("href").split("-")[1]
	print(links)
	print(deps_ver)

	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/junegunn/fzf/releases", is_json=True)
	version = None

	for item in json_data:
		try:
			if item["prerelease"] or item["draft"]:
				continue

			version = item["tag_name"]
			list(map(int, version.split(".")))
			if version == deps_ver:
				break

		except (KeyError, IndexError, ValueError):
			continue

	if version:
		final_name=f'fzf-{version}.tar.gz'
		url=f"https://github.com/junegunn/fzf/archive/{version}.tar.gz"
		depurl=f'https://dev.gentoo.org/~sam/distfiles/app-shells/fzf/fzf-{version}-deps.tar.xz'
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name),
					hub.pkgtools.ebuild.Artifact(url=depurl)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
