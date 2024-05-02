#!/usr/bin/env python3

import json
import re

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/util-linux/util-linux/tags", is_json=True)
	version = None
	BASEVER = re.compile('\d+\.\d+')

	for item in json_data:
		try:
			version = item["name"].strip('v')
			list(map(int, version.split(".")))
			break

		except (KeyError, IndexError, ValueError):
			continue

	if version:
		url = f"https://www.kernel.org/pub/linux/utils/util-linux/v{BASEVER.match(version).group()}/util-linux-{version}.tar.xz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			python_compat='python3+',
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=url.rsplit('/', 1)[-1])]
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
