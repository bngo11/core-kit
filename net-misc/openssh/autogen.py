#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/openssh/openssh-portable/tags", is_json=True)

	for item in json_data:
		version = None
		commit = None
		try:
			version = item["name"].lstrip("V_").replace("_", '.', 1).lower()
			print(version)
			list(map(int, version.split('_')[0].split(".")))
			commit = item["commit"]["sha"]
			break

		except (KeyError, IndexError, ValueError):
			continue

	if version and commit:
		final_name = f"openssh-portable-{version}-{commit[:7]}.tar.gz"
		url = f"https://github.com/openssh/openssh-portable/tarball/{commit}"

		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			sha=commit,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
