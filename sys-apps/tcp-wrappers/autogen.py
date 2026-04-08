#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	base_src_url = "http://deb.debian.org/debian/pool/main/t/tcp-wrappers"
	html_data = await hub.pkgtools.fetch.get_page(base_src_url)
	soup = BeautifulSoup(html_data, "html.parser")
	links = soup.find_all("a")
	links.reverse()
	version = debian_filename = orig_filename = None

	for link in links:
		href = link.get("href")
		if href and "tcp-wrappers" in href:
			if 'orig.tar.gz' in href:
				orig_filename = href
			elif 'debian.tar.xz' in href:
				debian_filename = href
			if orig_filename and debian_filename:
				break

	if orig_filename and debian_filename:
		parts = debian_filename.split("_")
		version_major, version_minor = parts[-1].rstrip('.debian.tar.xz').split('-')
		version = version_major.split(".")[:2]
		version.append(version_minor)
		version = ".".join(version)

	if version:
		orig_src_uri = f"{base_src_url}/{orig_filename}"
		debian_src_uri = f"{base_src_url}/{debian_filename}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[
				hub.pkgtools.ebuild.Artifact(url=orig_src_uri),
				hub.pkgtools.ebuild.Artifact(url=debian_src_uri),
			]
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
