# Prepare
balUtil = require('bal-util')

# Export
module.exports = (BasePlugin) ->
	# Define
	class GitHubPagesPlugin extends BasePlugin
		# Name
		name: 'ghpages'

		# Config
		config:
			deployBranch: 'gh-pages'
			sourceBranch: 'master'
			environment:  'static'

		# =============================
		# Events

		# Console Setup
		consoleSetup: (opts) ->
			# Prepare
			{consoleInterface,commander} = opts
			config = @config
			docpad = @docpad

			console.log 'add deploy-ghpages command'

			# Deploy
			commander
				.command('deploy-ghpages')
				.description("deploys your #{config.environment} website to the #{config.deployBranch} branch")
				.action consoleInterface.wrapAction (next) ->
					console.log 'do initial checkout here'
					docpad.action 'generate', {env:opts.environment}, (err) ->
						console.log 'do github deploy stuff here'
						next(err)

			# Chain
			@
