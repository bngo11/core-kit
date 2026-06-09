#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	url_host = pkginfo['gitlab']['url']
	dwnld_dir = pkginfo['gitlab']['dwnld_dir']
	projid = pkginfo['gitlab']['project_id']
	name = pkginfo['name']
	html_data = await hub.pkgtools.fetch.get_page(f"{url_host}/{dwnld_dir}")
	soup = BeautifulSoup(html_data, "html.parser")
	links = soup.find_all("a")
	links.reverse()
	version = final_name = None

	for link in links:
		final_name = link.get("href")
		if final_name and (final_name.endswith('tar.xz') or final_name.endswith('tar.bz2')):
			try:
				pkgname, parts = final_name.rsplit("-", 1)
				if pkgname == name:
					version = parts.rsplit('.', 2)[0]
					list(map(int, version.split(".")))
					break

			except (ValueError, AttributeError):
				continue

	if version and final_name:
		url = f"{url_host}/{dwnld_dir}/{final_name}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
