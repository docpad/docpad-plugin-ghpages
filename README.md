# [GitHub Pages](http://pages.github.com/) Deployer Plugin for [DocPad](http://docpad.org)

<!-- BADGES/ -->

<span class="badge-travisci"><a href="http://travis-ci.org/docpad/docpad-plugin-ghpages" title="Check this project's build status on TravisCI"><img src="https://img.shields.io/travis/docpad/docpad-plugin-ghpages/master.svg" alt="Travis CI Build Status" /></a></span>
<span class="badge-npmversion"><a href="https://npmjs.org/package/docpad-plugin-ghpages" title="View this project on NPM"><img src="https://img.shields.io/npm/v/docpad-plugin-ghpages.svg" alt="NPM version" /></a></span>
<span class="badge-npmdownloads"><a href="https://npmjs.org/package/docpad-plugin-ghpages" title="View this project on NPM"><img src="https://img.shields.io/npm/dm/docpad-plugin-ghpages.svg" alt="NPM downloads" /></a></span>
<span class="badge-daviddm"><a href="https://david-dm.org/docpad/docpad-plugin-ghpages" title="View the status of this project's dependencies on DavidDM"><img src="https://img.shields.io/david/docpad/docpad-plugin-ghpages.svg" alt="Dependency Status" /></a></span>
<span class="badge-daviddmdev"><a href="https://david-dm.org/docpad/docpad-plugin-ghpages#info=devDependencies" title="View the status of this project's development dependencies on DavidDM"><img src="https://img.shields.io/david/dev/docpad/docpad-plugin-ghpages.svg" alt="Dev Dependency Status" /></a></span>
<br class="badge-separator" />
<span class="badge-patreon"><a href="https://patreon.com/bevry" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-gratipay"><a href="https://www.gratipay.com/bevry" title="Donate weekly to this project using Gratipay"><img src="https://img.shields.io/badge/gratipay-donate-yellow.svg" alt="Gratipay donate button" /></a></span>
<span class="badge-flattr"><a href="https://flattr.com/profile/balupton" title="Donate to this project using Flattr"><img src="https://img.shields.io/badge/flattr-donate-yellow.svg" alt="Flattr donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
<span class="badge-bitcoin"><a href="https://bevry.me/bitcoin" title="Donate once-off to this project using Bitcoin"><img src="https://img.shields.io/badge/bitcoin-donate-yellow.svg" alt="Bitcoin donate button" /></a></span>
<span class="badge-wishlist"><a href="https://bevry.me/wishlist" title="Buy an item on our wishlist for us"><img src="https://img.shields.io/badge/wishlist-donate-yellow.svg" alt="Wishlist browse button" /></a></span>
<br class="badge-separator" />
<span class="badge-slackin"><a href="https://slack.bevry.me" title="Join this project's slack community"><img src="https://slack.bevry.me/badge.svg" alt="Slack community badge" /></a></span>

<!-- /BADGES -->


Deploy to Github Pages easily via `docpad deploy-ghpages`


<!-- INSTALL/ -->

<h2>Install</h2>

Install this DocPad plugin by entering <code>docpad install ghpages</code> into your terminal.

<!-- /INSTALL -->


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
Depending on circumstances, the github pages plugin might not work and you'll see an error. You can debug this by running the deploy with the `-d` flag like so `docpad deploy-ghpages -d`. That will tell you at which step the deploy failed.

- If the deploy fails fetching the origin remote, it means that you do not have the remote "origin", you will need to add it, or update the `deployRemote` setting to reflect your desired remote.

- If the deploy fails on the push to github pages, you may need to specify your username and password within the remote. You can do this by running:

	``` bash
	node -e "console.log('https://'+encodeURI('USERNAME')+':'+encodeURI('PASSWORD')+'@github.com/REPO_OWNER/REPO_NAME.git')"
	```

	Replace the words in capitals with their actual values and press enter. This will then output the new remote URL, you then want to copy it and run `git remote rm origin` and `git remote add origin THE_NEW_URL` and try the deploy again.

	On OSX you may be able to avoid this step by running `git config --global credential.helper osxkeychain` to tell git to save the passwords to the OSX keychain rather than asking for them every single time.

- If you get EPERM or unlink errors, it means that DocPad does not have permission to clean up the git directory that it creates in the out folder. You must clean this up manually yourself by running `rm -Rf ./out/.git`



<!-- HISTORY/ -->

<h2>History</h2>

<a href="https://github.com/docpad/docpad-plugin-ghpages/blob/master/HISTORY.md#files">Discover the release history by heading on over to the <code>HISTORY.md</code> file.</a>

<!-- /HISTORY -->


<!-- CONTRIBUTE/ -->

<h2>Contribute</h2>

<a href="https://github.com/docpad/docpad-plugin-ghpages/blob/master/CONTRIBUTING.md#files">Discover how you can contribute by heading on over to the <code>CONTRIBUTING.md</code> file.</a>

<!-- /CONTRIBUTE -->


<!-- BACKERS/ -->

<h2>Backers</h2>

<h3>Maintainers</h3>

These amazing people are maintaining this project:

<ul><li><a href="http://blog.atomicinc.com">Avi Deitcher</a> — <a href="https://github.com/docpad/docpad-plugin-ghpages/commits?author=deitch" title="View the GitHub contributions of Avi Deitcher on repository docpad/docpad-plugin-ghpages">view contributions</a></li>
<li><a href="http://balupton.com">Benjamin Lupton</a> — <a href="https://github.com/docpad/docpad-plugin-ghpages/commits?author=balupton" title="View the GitHub contributions of Benjamin Lupton on repository docpad/docpad-plugin-ghpages">view contributions</a></li>
<li><a href="https://github.com/sergeylukin">Sergey Lukin</a> — <a href="https://github.com/docpad/docpad-plugin-ghpages/commits?author=sergeylukin" title="View the GitHub contributions of Sergey Lukin on repository docpad/docpad-plugin-ghpages">view contributions</a></li></ul>

<h3>Sponsors</h3>

No sponsors yet! Will you be the first?

<span class="badge-patreon"><a href="https://patreon.com/bevry" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-gratipay"><a href="https://www.gratipay.com/bevry" title="Donate weekly to this project using Gratipay"><img src="https://img.shields.io/badge/gratipay-donate-yellow.svg" alt="Gratipay donate button" /></a></span>
<span class="badge-flattr"><a href="https://flattr.com/profile/balupton" title="Donate to this project using Flattr"><img src="https://img.shields.io/badge/flattr-donate-yellow.svg" alt="Flattr donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
<span class="badge-bitcoin"><a href="https://bevry.me/bitcoin" title="Donate once-off to this project using Bitcoin"><img src="https://img.shields.io/badge/bitcoin-donate-yellow.svg" alt="Bitcoin donate button" /></a></span>
<span class="badge-wishlist"><a href="https://bevry.me/wishlist" title="Buy an item on our wishlist for us"><img src="https://img.shields.io/badge/wishlist-donate-yellow.svg" alt="Wishlist browse button" /></a></span>

<h3>Contributors</h3>

These amazing people have contributed code to this project:

<ul><li><a href="http://blog.atomicinc.com">Avi Deitcher</a> — <a href="https://github.com/docpad/docpad-plugin-ghpages/commits?author=deitch" title="View the GitHub contributions of Avi Deitcher on repository docpad/docpad-plugin-ghpages">view contributions</a></li>
<li><a href="http://balupton.com">Benjamin Lupton</a> — <a href="https://github.com/docpad/docpad-plugin-ghpages/commits?author=balupton" title="View the GitHub contributions of Benjamin Lupton on repository docpad/docpad-plugin-ghpages">view contributions</a></li>
<li><a href="http://www.bricolage.io">Kyle Mathews</a> — <a href="https://github.com/docpad/docpad-plugin-ghpages/commits?author=KyleAMathews" title="View the GitHub contributions of Kyle Mathews on repository docpad/docpad-plugin-ghpages">view contributions</a></li>
<li><a href="http://robloach.net">Rob Loach</a> — <a href="https://github.com/docpad/docpad-plugin-ghpages/commits?author=RobLoach" title="View the GitHub contributions of Rob Loach on repository docpad/docpad-plugin-ghpages">view contributions</a></li>
<li><a href="https://github.com/sergeylukin">Sergey Lukin</a> — <a href="https://github.com/docpad/docpad-plugin-ghpages/commits?author=sergeylukin" title="View the GitHub contributions of Sergey Lukin on repository docpad/docpad-plugin-ghpages">view contributions</a></li>
<li><a href="https://github.com/vsopvsop">vsopvsop</a> — <a href="https://github.com/docpad/docpad-plugin-ghpages/commits?author=vsopvsop" title="View the GitHub contributions of vsopvsop on repository docpad/docpad-plugin-ghpages">view contributions</a></li></ul>

<a href="https://github.com/docpad/docpad-plugin-ghpages/blob/master/CONTRIBUTING.md#files">Discover how you can contribute by heading on over to the <code>CONTRIBUTING.md</code> file.</a>

<!-- /BACKERS -->


<!-- LICENSE/ -->

<h2>License</h2>

Unless stated otherwise all works are:

<ul><li>Copyright &copy; 2013+ <a href="http://bevry.me">Bevry Pty Ltd</a></li></ul>

and licensed under:

<ul><li><a href="http://spdx.org/licenses/MIT.html">MIT License</a></li></ul>

<!-- /LICENSE -->
