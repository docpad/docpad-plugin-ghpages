# Prepare
safeps = require('safeps')
balUtil = require('bal-util')
pathUtil = require('path')
async = require('async')
cp = require('child_process')



# Export
module.exports = (BasePlugin) ->
	# Define
	class GhpagesPlugin extends BasePlugin
		# Name
		name: 'ghpages'

		# Config
		config:
			deployRemote: 'origin'
			deployBranch: 'gh-pages'
			environment:  'static'

		# to do actual deploy
		_doDeploy: (me,docpad) ->
			return (opts,next) ->

				# Fetch the latest plugin configuration
				config = me.getConfig()

				# Fetch latest DocPad configuration
				{outPath,rootPath} = docpad.getConfig()

				# Log
				docpad.log 'info', 'Deployment to GitHub Pages starting...'


				# Prepare
				if outPath is rootPath
					err = new Error("Your outPath configuration has been customised. Please remove the customisation in order to use the GitHub Pages plugin")
					return next(err)
				outGitPath = pathUtil.join(outPath,'.git')


				# Remove the out git repo if it exists
				balUtil.rmdirDeep outGitPath, (err) ->
					# Error?
					return next(err)  if err


					# Log
					docpad.log 'debug', 'Removing old ./out/.git directory..'

					# Remove the out git repo if it exists
					balUtil.rmdirDeep outGitPath, (err) ->
						# Error?
						return next(err)  if err

						# Log
						docpad.log 'debug', 'Performing static generation...'

						# Generate the static environment to out
						docpad.generate {env:config.environment}, (err) ->
							# Error?
							return next(err)  if err

							# Log
							docpad.log 'debug', "Fetching the URL of the {config.deployRemote} remote..."

							# Fetch the project's remote url so we can push to it in our new git repo
							safeps.spawnCommand 'git', ['config', "remote.#{config.deployRemote}.url"], {cwd:rootPath}, (err,stdout,stderr) ->
								# Error?
								return next(err)  if err

								# Extract
								remoteRepoUrl = stdout.replace(/\n/,"")
								
								
								# Log
								docpad.log 'debug', 'Fetching log messages...'

								# Fetch the last log so we can add a meaningful commit message
								safeps.spawnCommand 'git', ['log', '--oneline'], {cwd:rootPath}, (err,stdout,stderr) ->
									# Error?
									return next(err)  if err

									# Extract
									lastCommit = stdout.split('\n')[0]

									# Log
									docpad.log 'debug', 'Fetching log messages...'


									# Initialize a git repo inside the out directory
									# and push it to the deploy branch
									gitCommands = [
										'git init',
										'git add .',
										'git commit -m '+ lastCommit,
										'git push --force '+remoteRepoUrl+" master:#{config.deployBranch}"
									]
									async.each gitCommands, cp.exec, (err,stdout,stderr) ->
										# Log
										docpad.log 'debug', 'Removing new ./out/.git directory..'

										# Now that deploy is done, remove the out git repo
										balUtil.rmdirDeep outGitPath, (err) ->
											# Error?
											return next(err)  if err

										# Log
										docpad.log('info', 'Deployment to GitHub Pages completed successfully')

										# Done
										return next()

		# =============================
		# Events
		docpadReady: (opts) ->

			# Let's try this way
			@docpad.setInstanceConfig({env:@config.environment})
			@docpad[@name] = @_doDeploy(@,@docpad)
			

		# Console Setup
		consoleSetup: (opts) ->
			config = @config
			# Prepare
			{consoleInterface,commander} = opts

			# Let's try this way
			@docpad.setInstanceConfig({env:config.environment})

			# Deploy command
			commander
				.command('deploy-ghpages')
				.description("deploys your #{config.environment} website to the #{config.deployRemote}/#{config.deployBranch} branch")
				.action consoleInterface.wrapAction @_doDeploy(@,@docpad)


			# Chain
			@
