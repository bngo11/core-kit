#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	html_data = await hub.pkgtools.fetch.get_page("https://jedsoft.org/releases/most")
	soup = BeautifulSoup(html_data, "html.parser")
	links = soup.find_all("a")
	version = None
	final_name = None

	for link in links:
		try:
			final_name = link.get("href")
			if final_name and final_name.startswith("most-") and final_name.endswith("tar.gz"):
				version = final_name.split("-")[1].rstrip(".tar.gz")
				list(map(int, version.split(".")))
				break

		except ValueError:
			continue
	else:
		version = None
		final_name = None

	if version and final_name:
		url = f"https://www.jedsoft.org/releases/most/{final_name}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
