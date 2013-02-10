# GitHub Pages Deployer Plugin for [DocPad](http://docpad.org)

Plugin to ease deployment of docpad-generated sites to GitHub Pages.

## Usage
Really simple to use:

````
docpad deploy-ghpages
````

## How It Works
docpad normally generates your static site html pages and assets to `./out`. Great, but GitHub Pages (GHP) expects them in `./`. Of course, if you do it in both, you end up with a mess, multiple copies (which really upsets SEO), and checks in the generated pages in your master repo unnecessarily.

deploy-ghpages takes care of all of that, with a few automated steps. When you run `docpad deploy-ghpages`, docpad does the following:

1. run `docpad generate --env static` to generate your static site
2. get the URL of your remote repo name using `git config remote.origin.url`
3. change directory to `./out` which is where your static site was generated
4. initialize a new git repo *inside* your `./out`. Yes, really, it makes sense, watch.
5. adds everything in `./out` to the new repo, and commits
6. does a `git push` of this new repo - essentially all the static content you want in GHP - to your repo to the branch `ghpages`, which is the "magical" repo where GHP expects your content in `./`
7. removes the `.git` directory, and so eliminate any local git repo
8. change directory back up to your root

Pretty much all of those steps were the brainchild of Sergey Lukin, see https://github.com/bevry/docpad/issues/385


## History
You can discover the history inside the `History.md` file


## Contributors
Benjamin Lupton http://github.com/balupton
Avi Deitcher http://github.com/deitch
Sergey Lukin http://github.com/sergeylukin

## License
Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT License](http://creativecommons.org/licenses/MIT/)
<br/>Copyright &copy; 2013+ [Bevry Pty Ltd](http://bevry.me)