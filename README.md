# [GitHub Pages](http://pages.github.com/) Deployer Plugin for [DocPad](http://docpad.org)

[![NPM version](https://badge.fury.io/js/docpad-plugin-ghpages.png)](https://npmjs.org/package/docpad-plugin-ghpages "View this project on NPM")
[![Flattr donate button](https://raw.github.com/balupton/flattr-buttons/master/badge-89x18.gif)](http://flattr.com/thing/344188/balupton-on-Flattr "Donate monthly to this project using Flattr")
[![PayPayl donate button](https://www.paypalobjects.com/en_AU/i/btn/btn_donate_SM.gif)](https://www.paypal.com/au/cgi-bin/webscr?cmd=_flow&SESSION=IHj3DG3oy_N9A9ZDIUnPksOi59v0i-EWDTunfmDrmU38Tuohg_xQTx0xcjq&dispatch=5885d80a13c0db1f8e263663d3faee8d14f86393d55a810282b64afed84968ec "Donate once-off to this project using Paypal")

Deploy to Github Pages easily via `docpad deploy-ghpages`


## Install

```
docpad install ghpages
```


## Usage

### Project Pages
This plugin works with GitHub Pages for Projects (e.g. `http://username.github.io/project` via `gh-pages` branch on `https://github.com/username/project`) with no configuration or setup required.

Simply run `docpad deploy-ghpages --env static` to deploy the contents of your `out` directory directly to your repository's `gh-pages` branch.


### Profile/Organisation Pages
This plugin also works with GitHub Pages for Profiles and Organisations (e.g. `http://username.github.io` via `master` branch on `https://github.com/username/username.github.io`) via any of the following options:

#### Two Repositories
Setup one repository called `username.github.io` which will be your target repository, and one called `website` which will be your source repository.

Inside your `website` repository, add the following to your [docpad configuration file](http://docpad.org/docs/config):

``` coffee
plugins:
	ghpages:
		deployRemote: 'target'
		deployBranch: 'master'
```

And run the following in terminal:

```
git remote add target https://github.com/username/username.github.io.git
```

Then when you run `docpad deploy-ghpages --env static` inside your website repository, the generated `out` directory will be pushed up to your target repository's `master` branch.


#### Multiple Branches
If you would like to have your source and generated site on the same repository, you can do this by the following.

Move the source of your website to the branch `source`, and the following to your [docpad configuration file](http://docpad.org/docs/config):

``` coffee
plugins:
	ghpages:
		deployRemote: 'origin'
		deployBranch: 'master'
```

Then when you run `docpad deploy-ghpages --env static` inside your website repository's `source` branch, the generated `out` directory will be pushed up to same repository's `master` branch.


#### Polluting the Root Directory
The final option is to not use this plugin and have the `out` directory be your website's root directory, so instead of say `your-website/src/documents/index.html` being outputted to `your-website/out/index.html`, instead it will be outputted to `you-website/index.html`. This is the way Jekyll works, however we don't recommend it as it is very messy and commits the out files into your repository.

To do this, add the following to your [docpad configuration file](http://docpad.org/docs/config):

``` coffee
outPath: '.'
```

### Custom Domains
If you're using [GitHub Pages Custom Domains](https://help.github.com/articles/setting-up-a-custom-domain-with-pages):

- Place your `CNAME` file at `src/files/CNAME` so it gets copied over to `out/CNAME` upon generation and consequently to the root of the `gh-pages` branch upon deployment
- Use a DocPad version 6.48.1 or higher


### Debugging
Dpendending on circumstances, maybe the github pages plugin won't work and you'll see an error. We can debug this by running the deploy with the `-d` flag like so `docpad deploy-ghpages -d`. That will tell us at which step the deploy failed.

- If the deploy fails fetching the origin remote, it means that you do not have the remote "origin", you will need to add it, or update the `deployRemote` setting to reflect your desired remote.

- If the deploy fails on the push to github pages, you may need to specify your username and password within the remote. You can do this by running:

	``` bash
	node -e "console.log('https://'+encodeURI('USERNAME')+':'+encodeURI('PASSWORD')+'@github.com/REPO_OWNER/REPO_NAME.git')"
	```

	Replace the words in capitals with their actual values and press enter. This will then output the new remote URL, you then want to copy it and run `git remote rm origin` and `git remote add origin THE_NEW_URL` and try the deploy again.

	On OSX you may be able to avoid this step by running `git config --global credential.helper osxkeychain` to tell git to save the passwords to the OSX keychain rather than asking for them every single time.

- If you get EPERM or unlink errors, it means that DocPad does not have permission to clean up the git directory that it creates in the out folder. You must clean this up manually yourself by running `rm -Rf ./out/.git`



## History
[You can discover the history inside the `History.md` file](https://github.com/bevry/docpad-plugin-ghpages/blob/master/History.md#files)


## Contributing
[You can discover the contributing instructions inside the `Contributing.md` file](https://github.com/bevry/docpad-plugin-ghpages/blob/master/Contributing.md#files)


## License
Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT License](http://creativecommons.org/licenses/MIT/)
<br/>Copyright &copy; 2013+ [Bevry Pty Ltd](http://bevry.me) <us@bevry.me>


## Contributors

- [Benjamin Lupton](http://github.com/balupton)
- [Avi Deitcher](http://github.com/deitch)
- [Sergey Lukin](http://github.com/sergeylukin)
