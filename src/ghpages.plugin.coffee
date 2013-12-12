# Prepare
safeps = require('safeps')
rimraf = require('rimraf')
pathUtil = require('path')

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
			environment: 'static'
			quiet: false

		# Do the Deploy
		deployToGithubPages: (next) =>
			# Prepare
			docpad = @docpad
			config = @getConfig()
			{outPath,rootPath} = docpad.getConfig()

			# Log
			docpad.log 'info', 'Deployment to GitHub Pages starting...'

			# Check paths
			if outPath is rootPath
				err = new Error("Your outPath configuration has been customised. Please remove the customisation in order to use the GitHub Pages plugin")
				return next(err)
			outGitPath = pathUtil.join(outPath,'.git')

			# Check environment
			if config.environment not in docpad.getEnvironments()
				err = new Error("Please run again using: docpad deploy-ghpages --env #{config.environment}")
				return next(err)

			# Log
			docpad.log 'debug', 'Removing old ./out/.git directory..'

			# Remove the out git repo if it exists
			rimraf outGitPath, (err) ->
				# Error?
				return next(err)  if err

				# Log
				docpad.log 'debug', 'Performing static generation...'

				# Generate the static environment to out
				docpad.generate (err) ->
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
							docpad.log 'debug', 'Performing push...'
							
							pushCommand = ['push', '--force', remoteRepoUrl, "master:#{config.deployBranch}"]
							pushCommand.push('--quiet') if config.quiet # useful to hide Personal Access Tokens when used in conjunction with Travis CI

							# Initialize a git repo inside the out directory
							# and push it to the deploy branch
							gitCommands = [
								['init']
								['add', '.']
								['commit', '-m', lastCommit]
								pushCommand
							]
							safeps.spawnCommands 'git', gitCommands, {cwd:outPath,stdio:'inherit'}, (err,stdout,stderr) ->
								# Error?
								return next(err)  if err

								# Log
								docpad.log('info', 'Deployment to GitHub Pages completed successfully')

								# Log
								docpad.log 'debug', 'Removing new ./out/.git directory..'

								# Now that deploy is done, remove the out git repo
								rimraf outGitPath, (err) ->
									# Error?
									return next(err)  if err

									# Done
									return next()


		# =============================
		# Events

		# Console Setup
		consoleSetup: (opts) =>
			# Prepare
			docpad = @docpad
			config = @getConfig()
			{consoleInterface,commander} = opts

			# Deploy command
			commander
				.command('deploy-ghpages')
				.description("Deploys your #{config.environment} website to the #{config.deployRemote}/#{config.deployBranch} branch")
				.action consoleInterface.wrapAction(@deployToGithubPages)

			# Chain
			@
