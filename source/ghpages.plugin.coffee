# Prepare
safeps = require('safeps')
rimraf = require('rimraf')
pathUtil = require('path')
safefs = require('safefs')
{TaskGroup} = require('taskgroup')

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

		# Do the Deploy
		deployToGithubPages: (next) =>
			# Prepare
			docpad = @docpad
			config = @getConfig()
			{outPath,rootPath} = docpad.getConfig()
			opts = {}

			# Log
			docpad.log 'info', 'Deployment to GitHub Pages starting...'

			# Tasks
			tasks = new TaskGroup().done(next)

			# Check paths
			tasks.addTask (complete) ->
				# Check
				if outPath is rootPath
					err = new Error("Your outPath configuration has been customised. Please remove the customisation in order to use the GitHub Pages plugin")
					return next(err)

				# Apply
				opts.outGitPath = pathUtil.join(outPath, '.git')

				# Complete
				return complete()

			# Check environment
			tasks.addTask (complete) ->
				# Check
				if config.environment not in docpad.getEnvironments()
					err = new Error("Please run again using: docpad deploy-ghpages --env #{config.environment}")
					return next(err)

				# Complete
				return complete()

			# Remove the out git repo if it exists
			tasks.addTask (complete) ->
				docpad.log 'debug', 'Removing old ./out/.git directory..'
				rimraf(opts.outGitPath, complete)

			# Generate the static environment to out
			tasks.addTask (complete) ->
				if process.argv.indexOf('--no-generate') isnt -1
					docpad.log 'debug', 'Skipping static generation...'
					complete()
				else
					docpad.log 'debug', 'Performing static generation...'
					docpad.action('generate', complete)

			# Add a .nojekyll file
			tasks.addTask (complete) ->
				docpad.log 'debug', 'Disabling jekyll...'
				safefs.writeFile(pathUtil.join(outPath, '.nojekyll'), '', complete)

			# Fetch the project's remote url so we can push to it in our new git repo
			tasks.addTask (complete) ->
				docpad.log 'debug', "Fetching the URL of the #{config.deployRemote} remote..."
				safeps.spawn ['git', 'config', "remote.#{config.deployRemote}.url"], {cwd:rootPath}, (err,stdout,stderr) ->
					# Error?
					return complete(err)  if err

					# Extract
					opts.remoteRepoUrl = stdout.toString().replace(/\n/, "")

					# Complete
					return complete()

			# Fetch the last log so we can add a meaningful commit message
			tasks.addTask (complete) ->
				docpad.log 'debug', 'Fetching log messages...'
				safeps.spawn ['git', 'log', '--oneline'], {cwd:rootPath}, (err,stdout,stderr) ->
					# Error?
					return complete(err)  if err

					# Extract
					opts.lastCommit = stdout.toString().split('\n')[0]

					# Complete
					return complete()

			# Initialize a git repo inside the out directory and push it to the deploy branch
			tasks.addTask (complete) ->
				docpad.log 'debug', 'Performing push...'
				gitCommands = [
					['git', 'init']
					['git', 'add', '--all', '--force']  # make sure we add absoutely everything in the out directory, even files that could be ignored by our global ignore file (like bower_components)
					['git', 'commit', '-m', opts.lastCommit]
					['git', 'push', '--quiet', '--force', opts.remoteRepoUrl, "master:#{config.deployBranch}"]
				]
				safeps.spawnMultiple gitCommands, {cwd:outPath, stdio:'inherit'}, (err) ->
					# Error?
					return complete(err)  if err

					# Log
					docpad.log('info', 'Deployment to GitHub Pages completed successfully')

					# Complete
					return complete()

			# Now that deploy is done, remove the out git repo
			tasks.addTask (complete) ->
				docpad.log 'debug', 'Removing new ./out/.git directory..'
				rimraf(opts.outGitPath, complete)

			# Start the deployment
			tasks.run()

			# Chain
			@


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
