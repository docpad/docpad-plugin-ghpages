# v1.1.0 June 12, 2013
# This file was originally created by Benjamin Lupton <b@lupton.cc> (http://balupton.com)
# and is currently licensed under the Creative Commons Zero (http://creativecommons.org/publicdomain/zero/1.0/)
# making it public domain so you can do whatever you wish with it without worry (you can even remove this notice!)
#
# If you change something here, be sure to reflect the changes in:
# - the scripts section of the package.json file
# - the .travis.yml file


# -----------------
# Variables

WINDOWS     = process.platform.indexOf('win') is 0
NODE        = process.execPath
NPM         = if WINDOWS then process.execPath.replace('node.exe','npm.cmd') else 'npm'
EXT         = (if WINDOWS then '.cmd' else '')
APP_DIR     = process.cwd()
SRC_DIR     = "#{APP_DIR}/src"
OUT_DIR     = "#{APP_DIR}/out"
TEST_DIR    = "#{APP_DIR}/test"
MODULES_DIR = "#{APP_DIR}/node_modules"
BIN_DIR     = "#{MODULES_DIR}/.bin"
DOCPAD_DIR  = "#{MODULES_DIR}/docpad"
CAKE        = "#{BIN_DIR}/cake#{EXT}"
COFFEE      = "#{BIN_DIR}/coffee#{EXT}"
DOCPAD      = "#{APP_DIR}/docpad#{EXT}"


# -----------------
# Requires

pathUtil = require('path')
{exec,spawn} = require('child_process')
safe = (next,fn) ->
	return (err) ->
		return next(err)  if err
		return fn()


# -----------------
# Actions

clean = (opts,next) ->
	(next = opts; opts = {})  unless next?
	args = [
		'-Rf'
		OUT_DIR
		pathUtil.join(APP_DIR, 'node_modules')
		pathUtil.join(APP_DIR, '*out')
		pathUtil.join(APP_DIR, '*log')
		pathUtil.join(TEST_DIR, 'node_modules')
		pathUtil.join(TEST_DIR, '*out')
		pathUtil.join(TEST_DIR, '*log')
	]
	spawn('rm', args, {stdio:'inherit', cwd:APP_DIR}).on 'exit', safe next, ->
		next()

compile = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(COFFEE, ['-bco', OUT_DIR, SRC_DIR], {stdio:'inherit', cwd:APP_DIR}).on 'exit', safe next, ->
		next()

watch = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(COFFEE, ['-bwco', OUT_DIR, SRC_DIR], {stdio:'inherit', cwd:APP_DIR}).on 'exit', safe next, ->
		next()

install = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(NPM, ['install'], {stdio:'inherit', cwd:APP_DIR}).on 'exit', safe next, ->
		spawn(NPM, ['install'], {stdio:'inherit', cwd:TEST_DIR}).on 'exit', safe next, ->
			next()

reset = (opts,next) ->
	(next = opts; opts = {})  unless next?
	clean opts, safe next, ->
		install opts, safe next, ->
			compile opts, safe next, ->
				next()

setup = (opts,next) ->
	(next = opts; opts = {})  unless next?
	install opts, safe next, ->
		compile opts, safe next, ->
			next()

test = (opts,next) ->
	(next = opts; opts = {})  unless next?
	compile opts, safe next, ->
		test_run opts, safe next, ->
			next()

test_run = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(NPM, ['test'], {stdio:'inherit', cwd:APP_DIR}).on 'exit', safe next, ->
		next()

test_install = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(NPM, ['install'], {stdio:'inherit', cwd:DOCPAD_DIR}).on 'exit', safe next, ->
		next()

test_setup = (opts,next) ->
	(next = opts; opts = {})  unless next?
	install opts, safe next, ->
		test_install opts, safe next, ->
			compile opts, safe next, ->
				next()

finish = (err) ->
	throw err  if err
	console.log('OK')


# -----------------
# Commands

# clean
task 'clean', 'clean up instance', ->
	clean finish

# compile
task 'compile', 'compile our files', ->
	compile finish

# dev/watch
task 'dev', 'watch and recompile our files', ->
	watch finish
task 'watch', 'watch and recompile our files', ->
	watch finish

# install
task 'install', 'install dependencies', ->
	install finish

# reset
task 'reset', 'reset instance', ->
	reset finish

# setup
task 'setup', 'setup for development', ->
	setup finish

# test
task 'test', 'run our tests', ->
	test finish

# test-debug
task 'test-debug', 'run our tests in debug mode', ->
	test {debug:true}, finish

# test-setup
task 'test-setup', 'setup for testing', ->
	test_setup finish
