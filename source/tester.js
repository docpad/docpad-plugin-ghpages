'use strict'

class GhpagesTester extends require('docpad-plugintester') {
	testCustom () {
		const tester = this
		this.test('deploy', function (complete) {
			tester.docpad.getPlugin('ghpages').deployToGithubPages().done(complete)
		})
		return this
	}
}


module.exports = GhpagesTester
