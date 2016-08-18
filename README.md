# ToolboxToolbox
Declarative dependency management for Matlab.

# Intro
The ToolboxToolbox is a declarative dependency management tool for Matlab.

This means you can write down the dependencies for your Matlab projects, in a JSON file.  Then the ToolboxToolbox will go go get them for you and put them on your Matlab path.

You can also share your JSON configuration files on the ToolboxHub's [ToolboxRegistry](https://github.com/ToolboxHub/ToolboxRegistry).  This makes it easy to share toolboxes and install them by name.

# Installation
To install the ToolboxToolbox itself, you have to get the code and do a little bit of setup.  The following should work on OS X or Linux:

Use [Git](https://git-scm.com/) to get the ToolboxToolbox code:
```
cd ~
git clone https://github.com/ToolboxHub/ToolboxToolbox.git
```

Set up your Matlab `userpath()` and `startup.m`.  These let Matlab find the ToolboxToolbox when it starts.  They also give you a `startup.m` which contains sensible defaults for ToolboxToolbox, like where to save installed toolboxes.  You can edit these defaults by editing your copy of `startup.m`.
```
cp -p ~/ToolboxToolbox/sampleStartup.m ~/Documents/MATLAB/startup.m
matlab -nosplash -nodesktop -r "userpath(fullfile(getenv('HOME'), 'Documents', 'MATLAB'));exit"
```

In Matlab, try deploying a sample toolbox called `sample-repo`, which contains a file called `master.txt`.  You should find find this file on your Matlab path.  
```
tbUse('sample-repo');
which master.txt
```

You should see something like the following:
```
>> tbUse('sample-repo')
Updating "ToolboxRegistry".
Obtaining "sample-repo".
Adding ToolboxToolbox to path at "/home/ben/ToolboxToolbox".
Adding "sample-repo" to path at "/home/ben/toolboxes/sample-repo".
Looks good: all toolboxes deployed OK.

>> which master.txt
/home/ben/toolboxes/sample-repo/master.txt
```


# Simpe Usages
See code, too

## Config in Matlab Struct

## Config in JSON

## Config from ToolboxHub Shared Registry

# Toolbox Records and Types
wiki page

# Write your own Strategy
wiki page

# Motivation
Here is a rant/motivation about declarative dependency management, Matlab, and the ToolboxToolbox.

Declarative dependency management tools are great.  They remove tedium and confusion from the process of wrangling dependencies, which helps keep projects healty developers productive.  There are lots of declarative dependency management tools out there.  For example:
 - [Maven](https://maven.apache.org/)
 - [Gradle](http://gradle.org/)
 - [Leiningen](http://leiningen.org/)
 - [Cargo](http://doc.crates.io/)
 - [pip](https://pypi.python.org/pypi/pip)
 - [apt](https://wiki.debian.org/Apt)
 - [Homebrew](http://brew.sh/)
 - many more!

These tools differ in details.  But a few key features rise to the top:
 - You  **declare** your dependencies in a config file or short script.  Then the tool does the work of obtaining them for you.
 - The dependencies can be declared **per project** where they are relevant and isolated, not per machine, per user, etc.
 - The tools can run **non-interactively**.  You don't have spend time clicking on things and remembering what you clicked on last time.
 - Configurations are shared in **public registries** of well-known dependencies.  So often, getting the dependency you need is a one-liner.
 
## Missing in Matlab
As far as I know, the ToolboxToolbox is the first declarative dependency management tool for Matlab.

The ToolboxToolbox handles two things for you and your Matlab projects:
 - Fetch the dependencies that you declared and cache them locally.  It can keep the cache updated with tools like Git, if desired.
 - Put the dependencies you declared on the Matlab path.  It can add to the current path, or reset the path to an absolute state based on the dependencies you declared.

The fetching part saves you from doing boring work.  The path management part solves several common headaches with Matlab workflows:
 - **The [Solera](https://en.wikipedia.org/wiki/Solera) Path.**  This is where your project works, but only because it secretly depends on a function you added to your path five years ago, or a Matlab toolbox you didn't know you installed 5 years ago.  When you try to share your project, you forget to tell people about this secret dependency, and your project breaks.
 - **The Shadow of the One Path.**  This is where your Matlab path has to serve all of the projects you are working with.  This leads to naming collisions and function shadowing, which lead to irritating bugs and manual path "fixes".
 - **The Monoloth Library.**  This is where users don't feel like installing lots of different toolboxes.  So in order to deliver new utilities to users, developers keep adding them to the same toolbox.  Eventually one toolbox becomes a monolith with lots of unrelated moving parts.
 - **The Orphan Utility.**  This is where you wrote a great utility that you want to share, but you don't know where to publish it so that others can easily get it and keep it updated.  It might end up in a Monolith Library, or being forgotten.
 - **The Missing binary.**  This is where you want to distribute binaries like mex-functions to users, but you don't want to include the binaries in the code repository.  So how are users supposed to get them?
 - **Version Hell.**  This is where you need to work with two different versions of the same library.  For example, during development, or because two otherwise awesome toolboxes happen to depend on different versions of another toolbox.  So which version should you put on your path?

The ToolboxToolbox should relieve all of these headaches.  Since the tedious parts are automated, it should be fine to include more, smaller dependencies like little utilities and mex-function binaries.  Likewise, large libraries can be broken down into smaller pieces and aggregated as declared dependencies, not as a single repository.

Since the Matlab path is configured automatically, it should be easier to understand and communicate exactly what belongs on the path.  It should also be a one-liner to switch between different projects and project versions.
