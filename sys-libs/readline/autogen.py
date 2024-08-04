#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	base_url = f"https://ftp.gnu.org/gnu/{pkginfo['name']}"
	html_data = await hub.pkgtools.fetch.get_page(base_url)
	soup = BeautifulSoup(html_data, "html.parser")
	links = soup.find_all("a", href = True)
	links.reverse()
	version = None
	base_version = None
	soname = None
	prestr = ['alpha', 'beta', 'rc', 'pr']
	release = []

	for link in links:
		try:
			contents = link.contents[0]
			name, ver = contents.split('-', 1)
			if ver.startswith('doc-'):
				continue
			if any(y in ver for y in prestr):
				continue

			version, extra = ver.split(".tar.gz")
			if extra:
				continue
			versplit = version.split('.')
			list(map(int, versplit))
			if versplit > release:
				release = versplit
				continue
			version = ".".join(release)
			base_version = ".".join(release[:2])
			soname = release[0]
			break
		except ValueError:
			continue

	if version:
		final_name = f"readline-{version}.tar.gz"
		url = f"{base_url}/{final_name}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			base_version=base_version,
			soname=soname,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
