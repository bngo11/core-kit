#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	url_host = pkginfo['gitlab']['url']
	dwnld_dir = pkginfo['gitlab']['dwnld_dir']
	projid = pkginfo['gitlab']['project_id']
	json_data = await hub.pkgtools.fetch.get_page(f"https://gitlab.freedesktop.org/api/v4/projects/{projid}/repository/tags", is_json=True)
	version = None
	final_name = None

	for item in json_data:
		try:
			version = item['name'].split('-')[-1].strip('v')
			list(map(int, version.split('.')))
			desc = item['release']['description'].split('\n')
			for d in desc:
				print(d)
				if not d.startswith('['):
					continue
				final_name = d.split('](')[0].strip('[')
				print(d, final_name)
				if final_name.endswith('sig') or final_name.endswith('sum'):
					continue
				break
			break

		except (IndexError, ValueError, KeyError, TypeError):
			continue
	else:
		version = None

	if version and final_name:
		url = f"{url_host}/{dwnld_dir}/{final_name}"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		ebuild.push()
# vim: ts=4 sw=4 noet
