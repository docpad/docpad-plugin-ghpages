# Prepare
balUtil = require('bal-util')
rimraf = require('rimraf')
exec = require('child_process').exec

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

			# because it does not seem to adopt the environment correctly
			docpad.config.env = config.environment;
			commander.env = config.environment;

			# Deploy
			commander
				.command('deploy-ghpages')
				.description("deploys your #{config.environment} website to the #{config.deployBranch} branch")
				.action consoleInterface.wrapAction (next) ->
					# generate the static environment to out
					docpad.action 'generate', {env:config.environment}, (err) ->
						# all of this courtesy of @sergeylukin
						# get the remote repo via 'git config remote.origin.url'
						exec 'git config remote.origin.url', (error,stdout,stderr) =>
							remote_repo = stdout.replace(/\n/,"")
							# change working directory to ./out
							process.chdir('./out')
							# git init
							# git add .
							# git commit -m'build'
							# git push $remote_repo master:$remote_branch --force
							gitCmd = 'git init && git add . && git commit -m\'build\' && git push '+remote_repo+' master:'+config.deployBranch+' --force'
							exec gitCmd, (error,stdout,stderr) =>
								# rm -rf .git
								rimraf '.git', () =>
									# change working directory back up to ../
									process.chdir('../')
									next(err)

			# Chain
			@
