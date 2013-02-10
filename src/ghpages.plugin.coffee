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

			console.log 'add deploy-ghpages command'

			# Deploy
			commander
				.command('deploy-ghpages')
				.description("deploys your #{config.environment} website to the #{config.deployBranch} branch")
				.action consoleInterface.wrapAction (next) ->
					console.log 'do initial checkout here'
					# generate the environment to out
					docpad.action 'generate', {env:opts.environment}, (err) ->
						console.log 'do github deploy stuff here'
						# all of this courtesy of @sergeylukin
						# get the remote repo via 'git config remote.origin.url'
						exec 'git config remote.origin.url' (error,stdout,stderr) =>
							remote_repo = stdout
							# change working directory to ./out
							process.chdir('./out')
							# set the remote branch to 'gh-pages' - the magical repo required by GitHub Pages
							remote_branch = 'gh-pages'
							# git init
							# git add .
							# git commit -m'build'
							# git push $remote_repo master:$remote_branch --force
							gitCmd = 'git init && git add . && git commit-m\'build\' && git push +'remote_repo+' master:'+remote_branch+' --force'
							exec gitCmd, (error,stdout,stderr) =>
								exec '' =>
									# rm -rf .git
									rimraf('.git') =>
										# change working directory back up to ../
										process.chdir('../')
										next(err)

			# Chain
			@
