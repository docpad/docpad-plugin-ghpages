/*jslint node:true, nomen:true, debug:true */
/*global it, before, after, describe */

// For this to work:
// resources/ needs to have "git init", "git add src/", "git commit -a -mTest", "git remote add git@github.com:docpad/docpad-plugin-ghpages-test.git"
// and when complete "rm -rf .git out/"

var sinon = require('sinon'),
should = require('should'),
childProcess = require('child_process'),
balUtil = require("bal-util"),
exec = childProcess.exec,
remote = "git@github.com:docpad/docpad-plugin-ghpages-test.git",
docpad,
plugins = [
__dirname+'/../../docpad-plugin-ghpages',
__dirname+'/../node_modules/docpad-plugin-eco',
__dirname+'/../node_modules/docpad-plugin-marked'
];

// debugger before anything
before(function(){
  debugger;
});

describe('ghpages', function(){
	before(function(done){
	  process.chdir('./test/resources');
		docpad = require('../node_modules/docpad/out/main');
		childProcess.exec("git init && git add src && git commit -a -mTest && git remote add origin "+remote,function (err,stdout,stderr) {
			done();
		});
	});
	after(function(done){
		balUtil.rmdirDeep("./out",done);
	});
	after(function(done){
		balUtil.rmdirDeep("./.git",done);
	});
  it('should give correct output command', function(done){
    var stub = sinon.stub(childProcess,"exec",function (cmd) {
			// now we need to break it down like the shell
			if (cmd && cmd.match(/^git push /)) {
				cmd.should.equal("git push --force "+remote+" master:gh-pages");
				stub.restore();
			} else {
				// just do whatever it would do
				exec.apply(childProcess,arguments);
			}
    });
		docpad.createInstance({pluginPaths:plugins,logLevel:6},function (err,docpadInstance) {
			docpadInstance.action('ghpages',function (err,result) {
				done();
			});
		});
  });
});