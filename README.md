# toolbox-toolbox
Declarative dependency management for Matlab.

# Motivation
In many development ecosystems, we enjoy dependency management tools.  These help us share, discover, and obtain our dependencies and make them available when we build and run our projects.
 - [Maven](https://maven.apache.org/)
 - [Gradle](http://gradle.org/)
 - [Leiningen](http://leiningen.org/)
 - [pip](https://pypi.python.org/pypi/pip)
 - [apt](https://wiki.debian.org/Apt)
 - [Homebrew](http://brew.sh/)
 - many more!
  
 These differ in their details.  But they have some key features in common:
 - You  *declare* your dependencies in a config file or short script.  Then the tool does the work of obtaining them for you.
 - The dependencies are declared *per program*, where they are relevant and isolated, and not per machine, per user, etc.
 - The tools can run *non-interactively*.  You don't have to waste time remembering what you clicked on last week.
 
These features are huge.  They prevent tedious documentation of the form "Install this, then install this if you are on Debian,  but not that if you are on Mountain Lion, etc..."  They enable good practives like automated building and testing.  They help us share our projects with others.  They help us compose projects out of small libraries that are focued and reusable.  They help us avoid the anti-pattern of writing monoliths that re-invent their dependencies, thus duplicating solved problems.

# Missing in Matlab
As far as I know, there is no such tool for the Matlab ecosystem.  Hence, this "Toolbox Toolbox".

The basic workflow will be like this: you declare your dependencies using some Matlab functions.  The Toolbox Toolbox writes these to a JSON file which you include with your project.  Then, anyone else who has the Toolbox Toolbox can use it, plus your JSON file, to get started with your project.  The Toolbox Toolbox will handle the details of downloading dependencies and configuring the Matlab path for them.

This will solve some frequent Matlab headaches that result from the fact that Matlab has only one, global path at a time.  What happens when you want to switch between projects or versions of projects?  Do you try to add all the projects you ever used to the Path?  What happens when projects define different functions with the same name?  What happens when you need to switch between incompatible versions of the same project?  Have you ever had a program that "works", only because it was secretly calling some obscure and unrelated function that you added to the path a year ago?  Enough!

The Toolbox Toolbox offers a different approach.  Don't manage your Matlab path.  Don't treat it as precious.  Be liberated and nimble and clear the Matlab path often.  Let the Toolbox Toolbox add path entries as declared in JSON files, when they are needed for a particular program.

# Work in Progress
The Toolbox Toolbox is a new project as of June 2016.  More to come...
