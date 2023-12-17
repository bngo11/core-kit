#!/usr/bin/env python3

from packaging import version
from bs4 import BeautifulSoup


async def generate(hub, **pkginfo):
	# url = f"http://cdn.postfix.johnriley.me/mirrors/postfix-release/"
	url = f"https://ghostarchive.org/postfix/postfix-release/"
	html_data = await hub.pkgtools.fetch.get_page(url)
	soup = BeautifulSoup(html_data, "html.parser")
	archives = {}
	for link in soup.find_all("a"):
		href = link.get("href")
		if href is not None and href.startswith("official") and href.endswith(".tar.gz"):
			ver = href.split(".tar")[0].split("-")[-1]
			if ver.upper().isupper():
				continue
			archives.update({ver:href})
	latest_version = sorted(archives, key=lambda x: version.parse(x)).pop()

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url+archives[latest_version], extra_http_headers={"Accept-Encoding" : "identity"})],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
