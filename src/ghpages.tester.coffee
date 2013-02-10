# Export Plugin Tester
module.exports = (testers) ->
    # Define Plugin Tester
    class GHPTester extends testers.RendererTester
        # Configuration
        docpadConfig:
            logLevel: 5
            enabledPlugins:
                'ghpages': true
                'eco': true
