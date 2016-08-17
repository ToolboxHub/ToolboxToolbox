# ToolboxToolbox
Declarative dependency management for Matlab.

# Installation

download / checkout
know your userpath
copy/edit sampleStartup.m to userpath/startup.m
start matlab

tbUse({'sample-repo'});
which master.txt

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
Declarative dependency management is great.  It makes dependency management easier, reproducible, and non-interactive.  This keeps projects healty developers productive.  There are lots of declarative dependency tools out there.  For example:
These tools include:
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
 - The [Solera](https://en.wikipedia.org/wiki/Solera) Path.  This is where your project works, but only because it secretly depends on a function you added to your path five years ago, or a Matlab toolbox you didn't know you installed 5 years ago.  When you try to share your project, you forget to tell people about this secret dependency, and your project breaks.
 - The Shadow of the One Path.  This is where your Matlab path has to serve all of the projects you are working with.  This leads to naming collisions and function shadowing, which lead to irritating bugs and manual path "fixes".
 - The Monoloth Library.  This is where users don't feel like installing lots of different toolboxes.  So in order to deliver new utilities to users, developers keep adding them to the same toolbox.  Eventually one toolbox becomes a monolith with lots of unrelated moving parts.
 - The Orphan Utility.  This is where you wrote a great utility that you want to share, but you don't know where to publish it so that others can easily get it and keep it updated.  It might end up in a Monolith Library, or being forgotten.
 - The Missing binary.  This is where you want to distribute binaries like mex-functions to users, but you don't want to include the binaries in the code repository.  So how are users supposed to get them?
 - Version Hell.  This is where you need to work with two different versions of the same library.  For example, during development, or because two otherwise awesome toolboxes happen to depend on different versions of another toolbox.  So which version should you put on your path?

The ToolboxToolbox should relieve all of these headaches.  Since the tedious parts are automated, it should be fine to include more, smaller dependencies like little utilities and mex-function binaries.  Likewise, large libraries can be broken down into smaller pieces and aggregated as declared dependencies, not as a single repository.  Since the Matlab path is configured automatically, it should be easier to understand and communicate exactly what belongs on the path.  It should also be a one-liner to switch between different projects and projec versions.
