#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	gitlabid = 12551088
	gitlaburl = "gitlab.com"
	json_data = await hub.pkgtools.fetch.get_page(f"https://{gitlaburl}/api/v4/projects/{gitlabid}/repository/tags", is_json=True)
	version = None
	url = None
	basever = pkginfo.get('basever')

	for item in json_data:
		try:
			version = item['name'].split('-')[-1]
			verlist = version.split(".")
			list(map(int, verlist))
			if len(verlist) > 1:
				if int(verlist[1]) >= 89 and int(verlist[0]) != 0:
					continue

			if basever:
				baselist = basever.split('.')
				baselen = len(baselist)
				if verlist[:baselen] != baselist:
					continue
			break

		except (IndexError, ValueError, KeyError):
			continue
	else:
		version = None

	if version:
		pkginfo['version'] = version
		final_name = f'{pkginfo["name"]}-{version}.tar.gz'
		url = f"https://sourceware.org/pub/bzip2/{final_name}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			soname=1,
			**pkginfo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		ebuild.push()
# vim: ts=4 sw=4 noet
