# Export Plugin Tester
module.exports = (testers) ->
	# Define My Tester
	class MyTester extends testers.RendererTester
		# Test Generate
		testGenerate: testers.RendererTester::testGenerate

		# Custom test
		testCustom: (next) ->
			@suite 'ghpages', (suite,test) ->
				test 'deploy', (complete) ->
					docpad.getPlugin('ghpages').deployToGithubPages(complete)
