#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	html_data = await hub.pkgtools.fetch.get_page("https://git.kernel.org/pub/scm/libs/klibc/klibc.git/refs/tags")
	soup = BeautifulSoup(html_data, "html.parser")
	links = soup.find_all("a")
	version = None

	for link in links:
		href = link.get("href")
		if href and "tag" in href:
			parts = href.split("/")
			version = parts[-1].split('-')[-1]

			try:
				list(map(int, version.split(".")))
				break

			except ValueError:
				continue

	hdr_data = await hub.pkgtools.fetch.get_page("https://www.kernel.org/releases.json", is_json=True)
	hdr_ver = hdr_data["latest_stable"]["version"].split(".")[:2]
	hdr_url = f"https://cdn.kernel.org/pub/linux/kernel/v{hdr_ver[0]}.x/linux-{'.'.join(hdr_ver)}.tar.xz"

	if version:
		url = f"https://git.kernel.org/pub/scm/libs/klibc/klibc.git/snapshot/klibc-{version}.tar.gz"
		final_name = url.rsplit('/', 1)[-1]
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name),
						hub.pkgtools.ebuild.Artifact(url=hdr_url)],
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
