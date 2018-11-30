/* eslint class-methods-use-this:0 */
'use strict'

// Prepare
const safeps = require('safeps')
const rimraf = require('rimraf')
const pathUtil = require('path')
const safefs = require('safefs')
const Errlop = require('errlop')
const { TaskGroup } = require('taskgroup')

// Export
module.exports = function (BasePlugin) {
	// Define
	return class GhpagesPlugin extends BasePlugin {
		// Name
		get name () {
			return 'ghpages'
		}

		// Config
		get initialConfig () {
			return {
				deployRemote: 'origin',
				deployBranch: 'gh-pages',
				environment: 'static'
			}
		}

		// Do the Deploy
		deployToGithubPages () {
			// Prepare
			const docpad = this.docpad
			const config = this.getConfig()
			const outPath = docpad.getPath(false, 'out')
			const rootPath = docpad.getPath('root')
			const opts = {}

			// Log
			docpad.log('info', 'Deployment to GitHub Pages is starting...')

			// Tasks
			const tasks = new TaskGroup().done(function (err) {
				if (err) {
					return docpad.fatal(new Errlop('Deployment to GitHub Pages has failed', err))
				}
				return docpad.log('info', 'Deployed to GitHub Pages')
			})

			// Check paths
			tasks.addTask(function (complete) {
				// Check
				if (outPath === rootPath) {
					const err = new Error('Your outPath configuration has been customised. Please remove the customisation in order to use the GitHub Pages plugin')
					return complete(err)
				}

				// Apply
				opts.outGitPath = pathUtil.join(outPath, '.git')

				// Complete
				return complete()
			})

			// Check environment
			tasks.addTask(function (complete) {
				// Check
				if (docpad.getEnvironments().includes(config.environment) === false) {
					const err = new Error(`Please run again using: docpad deploy-ghpages --env ${config.environment}`)
					return complete(err)
				}

				// Complete
				return complete()
			})

			// Remove the out git repo if it exists
			tasks.addTask(function (complete) {
				docpad.log('debug', 'Removing old ./out/.git directory..')
				rimraf(opts.outGitPath, complete)
			})

			// Generate the static environment to out
			tasks.addTask(function (complete) {
				if (process.argv.includes('--no-generate')) {
					docpad.log('debug', 'Skipping static generation...')
					complete()
				}
				else {
					docpad.log('debug', 'Performing static generation...')
					docpad.action('generate', complete)
				}
			})

			// Add a .nojekyll file
			tasks.addTask(function (complete) {
				docpad.log('debug', 'Disabling jekyll...')
				safefs.writeFile(pathUtil.join(outPath, '.nojekyll'), '', complete)
			})

			// Fetch the project's remote url so we can push to it in our new git repo
			tasks.addTask(function (complete) {
				docpad.log('debug', `Fetching the URL of the ${config.deployRemote} remote...`)
				const command = ['git', 'config', `remote.${config.deployRemote}.url`]
				safeps.spawn(command, { cwd: rootPath }, function (err, stdout) {
					// Error?
					if (err) {
						return complete(err)
					}

					// Extract
					opts.remoteRepoUrl = stdout.toString().replace(/\n/, '')

					// Complete
					return complete()
				})
			})

			// Fetch the last log so we can add a meaningful commit message
			tasks.addTask(function (complete) {
				docpad.log('debug', 'Fetching log messages...')
				const command = ['git', 'log', '--oneline']
				safeps.spawn(command, { cwd: rootPath }, function (err, stdout) {
					// Error?
					if (err) {
						return complete(err)
					}

					// Extract
					opts.lastCommit = stdout.toString().split('\n')[0]

					// Complete
					return complete()
				})
			})

			// Initialize a git repo inside the out directory and push it to the deploy branch
			// make sure we add absoutely everything in the out directory, even files that could be ignored by our global ignore file (like bower_components)
			tasks.addTask(function (complete) {
				docpad.log('info', `Performing push to ${opts.remoteRepoUrl}:${config.deployBranch}`)
				const gitCommands = [
					['git', 'init'],
					['git', 'add', '--all', '--force'],
					['git', 'commit', '-m', opts.lastCommit],
					['git', 'push', '--quiet', '--force', opts.remoteRepoUrl, `master:${config.deployBranch}`]
				]
				safeps.spawnMultiple(gitCommands, { cwd: outPath, stdio: 'inherit' }, function (err) {
					// Error?
					if (err) {
						return complete(err)
					}

					// Log
					docpad.log('info', 'Deployment to GitHub Pages completed successfully')

					// Complete
					return complete()
				})
			})

			// Now that deploy is done, remove the out git repo
			tasks.addTask(function (complete) {
				docpad.log('debug', 'Removing new ./out/.git directory...')
				rimraf(opts.outGitPath, complete)
			})

			// Start the deployment
			tasks.run()

			// Return the taskgroup so that our tester can do .done
			return tasks
		}


		// =============================
		// Events

		// Console Setup
		consoleSetup (opts) {
			// Prepare
			const config = this.getConfig()
			const cli = opts.cac

			// Deploy command
			cli.command('deploy-ghpages', {
				alias: ['deploy'],
				description: `Deploys your ${config.environment} website to the ${config.deployRemote}/${config.deployBranch} branch`
			}, this.deployToGithubPages.bind(this))

			// Chain
			return this
		}
	}
}

