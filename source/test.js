'use strict'

// Test our plugin using DocPad's Testers
require('./tester.js').test(
	{
		testerName: 'ghpages static environment',
	},
	{
		env: 'static',
		logLevel: 7,
	}
)
