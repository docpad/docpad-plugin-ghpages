# Test our plugin using DocPad's Testers
require('docpad-plugintester')
	.test(
		{
			testerName: 'ghpages static environment'
			pluginPath: __dirname+'/..'
		},
		{
			env: 'static'
			logLevel: 7
		}
	)
