#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/google/brotli/tags", is_json=True)
	version = None
	url = None

	for item in json_data:
		try:
			version = item['name'].strip('v')
			verlist = version.split(".")
			list(map(int, verlist))
			if len(verlist) > 1:
				if int(verlist[1]) >= 89 and int(verlist[0]) != 0:
					continue

			# if int(verlist[1]) % 2:
			# 	continue

			url = item['tarball_url']
			commit = item['commit']['sha'][:7]

			if version and url:
				break

		except (IndexError, ValueError, KeyError):
			continue
	else:
		version = None

	if version and url:
		final_name = f'brotli-{version}.tar.gz'
		pkginfo['version'] = version
		brotli = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			commit=commit,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		brotli.push()

		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			cat='dev-python',
			name='brotlipy',
			template='brotlipy.tmpl',
			template_path=brotli.template_path,
			version=version,
			artifacts=[],
		)
		ebuild.push()
# vim: ts=4 sw=4 noet
