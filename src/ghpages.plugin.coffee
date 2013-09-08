# Prepare
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
			deployBranch: 'gh-pages'
			environment:  'static'

		# to do actual deploy
		_doDeploy: (config,docpad) ->
			return (opts,next) ->

				# Log
				docpad.log 'info', 'Deployment to GitHub Pages starting...'

				# Prepare
				outPath = docpad.config.outPath
				return next("Cannot have config.outPath be repo root directory '.'") if outPath is '' or outPath is '.' or outPath is './'
				outGitPath = pathUtil.join(outPath,'.git')

				# Remove the out git repo if it exists
				balUtil.rmdirDeep outGitPath, (err) ->
					# Error?
					return next(err)  if err

					# Generate the static environment to out
					# docpad.action 'generate', {env:config.environment}, (err) ->
					docpad.generate {env:config.environment}, (err) ->
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
									'git init'
									'git add .'
									'git commit -m ' + lastCommit
									'git push --force '+ remoteRepoUrl+ " master:#{config.deployBranch}"
								]
								async.each gitCommands, cp.exec, (err) ->
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
			@docpad[@name] = @_doDeploy(@config,@docpad)
			

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
				.description("deploys your #{config.environment} website to the #{config.deployBranch} branch")
				.action consoleInterface.wrapAction @_doDeploy(config,@docpad)

			# Chain
			@
