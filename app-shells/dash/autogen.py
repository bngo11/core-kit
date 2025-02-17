#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	html_data = await hub.pkgtools.fetch.get_page("https://git.kernel.org/pub/scm/utils/dash/dash.git")
	soup = BeautifulSoup(html_data, "html.parser")
	links = soup.find_all("a")
	version = None

	for link in links:
		part_url = link.get("href")
		if part_url and part_url.endswith("tar.gz"):
			final_name = part_url.rsplit("/", 1)[-1]
			version = final_name.rsplit("-", 1)[-1].rstrip(".tar.gz")

			try:
				list(map(int, version.split(".")))
				break

			except ValueError:
				continue

	if version:
		url = f"https://git.kernel.org{part_url}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
