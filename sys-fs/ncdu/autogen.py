#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	html_data = await hub.pkgtools.fetch.get_page("https://code.blicky.net/yorhel/ncdu/tags")
	soup = BeautifulSoup(html_data, "html.parser")
	links = soup.find_all("a")
	version = None
	basever = "2"

	for link in links:
		href = link.get("href")
		if href and "tag" in href:
			parts = href.split("/")
			version = parts[-1].lstrip("v")

			try:
				verlist = version.split(".")
				list(map(int, verlist))
				if verlist[0] == basever:
					break

			except ValueError:
				continue

	if version:
		final_name = f"ncdu-{version}.tar.gz"
		url = f"https://dev.yorhel.nl/download/{final_name}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
