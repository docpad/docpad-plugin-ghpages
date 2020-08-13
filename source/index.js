// @ts-nocheck
'use strict'

// Prepare
const safeps = require('safeps')
const rimraf = require('rimraf')
const pathUtil = require('path')
const safefs = require('safefs')
const { TaskGroup } = require('taskgroup')

// Export
module.exports = function (BasePlugin) {
	// Define
	return class GhpagesPlugin extends BasePlugin {
		// Name
		get name() {
			return 'ghpages'
		}

		// Config
		get initialConfig() {
			return {
				deployRemote: 'origin',
				deployBranch: 'gh-pages',
				environment: 'static',
			}
		}

		// Do the Deploy
		deployToGithubPages(next) {
			// Prepare
			const { docpad } = this
			const config = this.getConfig()
			const outPath = docpad.getPath('out')
			const rootPath = docpad.getPath('root')
			const opts = {}

			// Log
			docpad.log('info', 'Deployment to GitHub Pages starting...')

			// Tasks
			const tasks = new TaskGroup().done(next)

			// Check paths
			tasks.addTask(function (complete) {
				// Check
				if (outPath === rootPath) {
					const err = new Error(
						'Your outPath configuration has been customised. Please remove the customisation in order to use the GitHub Pages plugin'
					)
					return next(err)
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
					const err = new Error(
						'Please run again using: docpad deploy-ghpages --env ${config.environment}'
					)
					return next(err)
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
				} else {
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
				docpad.log(
					'debug',
					`Fetching the URL of the ${config.deployRemote} remote...`
				)
				safeps.spawn(
					['git', 'config', `remote.${config.deployRemote}.url`],
					{ cwd: rootPath },
					function (err, stdout) {
						// Error?
						if (err) return complete(err)

						// Extract
						opts.remoteRepoUrl = stdout.toString().replace(/\n/, '')

						// Complete
						return complete()
					}
				)
			})

			// Fetch the last log so we can add a meaningful commit message
			tasks.addTask(function (complete) {
				docpad.log('debug', 'Fetching log messages...')
				safeps.spawn(['git', 'log', '--oneline'], { cwd: rootPath }, function (
					err,
					stdout,
					stderr
				) {
					// Error?
					if (err) return complete(err)

					// Extract
					opts.lastCommit = stdout.toString().split('\n')[0]

					// Complete
					return complete()
				})
			})

			// Initialize a git repo inside the out directory and push it to the deploy branch
			tasks.addTask(function (complete) {
				docpad.log('debug', 'Performing push...')
				const gitCommands = [
					['git', 'init'],
					// make sure we add absoutely everything in the out directory, even files that could be ignored by our global ignore file (like bower_components)
					['git', 'add', '--all', '--force'],
					['git', 'commit', '-m', opts.lastCommit],
					[
						'git',
						'push',
						'--quiet',
						'--force',
						opts.remoteRepoUrl,
						`master:${config.deployBranch}`,
					],
				]
				safeps.spawnMultiple(
					gitCommands,
					{ cwd: outPath, stdio: 'inherit' },
					function (err) {
						// Error?
						if (err) return complete(err)

						// Log
						docpad.log(
							'info',
							'Deployment to GitHub Pages completed successfully'
						)

						// Complete
						return complete()
					}
				)
			})

			// Now that deploy is done, remove the out git repo
			tasks.addTask(function (complete) {
				docpad.log('debug', 'Removing new ./out/.git directory..')
				rimraf(opts.outGitPath, complete)
			})

			// Start the deployment
			tasks.run()
		}

		// =============================
		// Events

		// Console Setup
		consoleSetup(opts) {
			// Prepare
			const me = this
			const config = this.getConfig()
			const { cac } = opts

			// Deploy command
			cac
				.command(
					'deploy-ghpages',
					`Deploys your ${config.environment} website to the ${config.deployRemote}/${config.deployBranch} branch`
				)
				.action(function () {
					return me.deployToGithubPages()
				})
		}
	}
}
