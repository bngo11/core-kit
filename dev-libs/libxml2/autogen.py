#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page(f"https://gitlab.gnome.org/api/v4/projects/1665/releases", is_json=True)
	version = None
	url = None

	for item in json_data:
		try:
			version = item['name'].split(' ')[-1]
			verlist = version.split(".")
			list(map(int, verlist))
			if len(verlist) > 1:
				if int(verlist[1]) >= 89 and int(verlist[0]) != 0:
					continue

			if int(verlist[1]) % 2:
				continue

			url = item['assets']['links'][0]['direct_asset_url']

			if version and url:
				break

		except (IndexError, ValueError, KeyError):
			continue
	else:
		version = None

	if version and url:
		pkginfo['version'] = version
		pkginfo['test_src_uri'] = '''		https://www.w3.org/XML/2004/xml-schema-test-suite/xmlschema2002-01-16/xsts-2002-01-16.tar.gz
            https://www.w3.org/XML/2004/xml-schema-test-suite/xmlschema2004-01-14/xsts-2004-01-14.tar.gz
            https://www.w3.org/XML/Test/xmlts20130923.tar.gz'''
		libxml2 = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=url.rsplit('/', 1)[-1])]
		)
		libxml2.push()

		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			cat='dev-python',
			name='libxml2-python',
			template='libxml2-python.tmpl',
			template_path=libxml2.template_path,
			version=version,
			artifacts=[],
		)
		ebuild.push()
# vim: ts=4 sw=4 noet
