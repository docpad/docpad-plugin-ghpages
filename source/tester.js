// @ts-nocheck
'use strict'

const PluginTester = require('docpad-plugintester')

class CustomTester extends PluginTester {
	testCustom() {
		const tester = this
		this.suite('ghpages', function (suite, test) {
			test('deploy', function (complete) {
				tester.docpad.getPlugin('ghpages').deployToGithubPages(complete)
			})
		})
	}
}

module.exports = CustomTester
