#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	html_data = await hub.pkgtools.fetch.get_page("https://git.kernel.org/pub/scm/fs/xfs/xfsprogs-dev.git")
	soup = BeautifulSoup(html_data, "html.parser")
	links = soup.find_all("a")
	version = None

	for link in links:
		try:
			href = link.get("href")
			if href and "tag" in href:
				parts = href.split("/")
				version = parts[-1].split("=")[-1].strip("v")
				list(map(int, version.split(".")))
				break

		except (IndexError, KeyError, ValueError):
			continue

	if version:
		url = f"https://www.kernel.org/pub/linux/utils/fs/xfs/xfsprogs/xfsprogs-{version}.tar.xz"
		final_name = f"xfsprogs-{version}.tar.xz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
