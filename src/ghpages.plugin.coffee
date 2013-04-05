# Prepare
balUtil = require('bal-util')
pathUtil = require('path')

# Export
module.exports = (BasePlugin) ->
	# Define
	class GhpagesPlugin extends BasePlugin
		# Name
		name: 'ghpages'

		# Config
		config:
			deployBranch: 'gh-pages'
			environment:  'static'

		# =============================
		# Events

		# Console Setup
		consoleSetup: (opts) ->
			# Prepare
			{consoleInterface,commander} = opts
			me = @
			config = @config
			docpad = @docpad

			# Let's try this way
			docpad.setInstanceConfig({env:config.environment})

			# Deploy command
			commander
				.command('deploy-ghpages')
				.description("deploys your #{config.environment} website to the #{config.deployBranch} branch")
				.action consoleInterface.wrapAction (next) ->

					# Log
					docpad.log 'info', 'Deployment to GitHub Pages starting...'

					# Prepare
					outPath = docpad.config.outPath
					outGitPath = pathUtil.join(outPath,'.git')

					# Remove the out git repo if it exists
					balUtil.rmdirDeep outGitPath, (err) ->
						# Error?
						return next(err)  if err

						# Generate the static environment to out
						docpad.action 'generate', {env:config.environment}, (err) ->
							# Error?
							return next(err)  if err

							# Fetch the project's remote url so we can push to it in our new git repo
							balUtil.spawnCommand 'git', ['config', 'remote.origin.url'], (err,stdout,stderr) ->
								# Error?
								return next(err)  if err

								# Extract
								remoteRepoUrl = stdout.replace(/\n/,"")

								# Fetch the last log so we can add a meaningful commit message
								balUtil.spawnCommand 'git', ['log', '--oneline'], (err,stdout,stderr) ->
									# Error?
									return next(err)  if err

									# Extract
									lastCommit = stdout.split('\n')[0]

									# Initialize a git repo inside the out directory
									# and push it to the deploy branch
									gitCommands = [
										['init']
										['add', '.']
										['commit', '-m', lastCommit]
										['push', '--force', remoteRepoUrl, "master:#{config.deployBranch}"]
									]
									balUtil.spawnCommands 'git', gitCommands, {cwd:outPath,output:true}, (err,stdout,stderr) ->
										# Error?
										return next(err)  if err

										# Now that deploy is done, remove the out git repo
										balUtil.rmdirDeep outGitPath, (err) ->
											# Error?
											return next(err)  if err

											# Log
											docpad.log('info', 'Deployment to GitHub Pages completed successfully')

											# Done
											return next()

			# Chain
			@
