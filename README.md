# ToolboxToolbox
Declarative dependency management for Matlab.

# Intro
The ToolboxToolbox is a declarative dependency management tool for Matlab.

This means you can write down the dependencies for your Matlab projects, in a Matlab struct or JSON file.  Then the ToolboxToolbox will go get them for you and put them on your Matlab path.

You can also share your JSON configuration files on the ToolboxHub's [ToolboxRegistry](https://github.com/ToolboxHub/ToolboxRegistry).  This makes it easy to share toolboxes and install them by name.

Here's some more about [what motivated the ToolboxToolbox](https://github.com/ToolboxHub/ToolboxToolbox/wiki/Motivation).

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
matlab -nodisplay -r "userpath(fullfile(getenv('HOME'), 'Documents', 'MATLAB'));exit"
```

## Test It
In Matlab, try deploying a sample toolbox called [sample-repo](https://github.com/ToolboxHub/sample-repo), which contains a file called `master.txt`.  You should find this file on your Matlab path.  
```
tbUse('sample-repo');
which master.txt
```

You should see results like the following:
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
Here are some simple usage examples for ToolboxToolbox.  There are more examples in the [ToolboxToolbox code](https://github.com/ToolboxHub/ToolboxToolbox/tree/master/examples).

## Config in Matlab Struct
You can declare toolboxes that you want in a Matlab struct, and deploy them directly from the struct.  Here's an example that obtains the [sample-repo](https://github.com/ToolboxHub/sample-repo) using Git.
```
record = tbToolboxRecord('name', 'sample-repo', 'type', 'git', 'url', 'https://github.com/ToolboxHub/sample-repo.git');
tbDeployToolboxes('config', record);
which master.txt
```

You should see results like this:
```
>> record = tbToolboxRecord('name', 'sample-repo', 'type', 'git', 'url', 'https://github.com/ToolboxHub/sample-repo.git');
>> tbDeployToolboxes('config', record);
Updating "ToolboxRegistry".
Obtaining "sample-repo".
Adding ToolboxToolbox to path at "/home/ben/ToolboxToolbox".
Adding "sample-repo" to path at "/home/ben/toolboxes/sample-repo".
Looks good: all toolboxes deployed OK.

>> which master.txt
/home/ben/toolboxes/sample-repo/master.txt
>> 
```

## Config in JSON
You can also save your struct configuraiton in a JSON file to use later or share with others.
```
record = tbToolboxRecord('name', 'sample-repo', 'type', 'git', 'url', 'https://github.com/ToolboxHub/sample-repo.git');
configPath = fullfile(tempdir(), 'sample-config.json');
tbWriteConfig(record, 'configPath', configPath);
tbDeployToolboxes('configPath', configPath);
which master.txt
```

You should see results like this:
```
>> record = tbToolboxRecord('name', 'sample-repo', 'type', 'git', 'url', 'https://github.com/ToolboxHub/sample-repo.git');
>> configPath = fullfile(tempdir(), 'sample-config.json');
>> tbWriteConfig(record, 'configPath', configPath);
>> tbDeployToolboxes('configPath', configPath);
Updating "ToolboxRegistry".
Updating "sample-repo".
Adding ToolboxToolbox to path at "/home/ben/ToolboxToolbox".
Adding "sample-repo" to path at "/home/ben/toolboxes/sample-repo".
Looks good: all toolboxes deployed OK.

>> which master.txt
/home/ben/toolboxes/sample-repo/master.txt
```

## Config from ToolboxHub ToolboxRegistry
So far so good.

But things get really fun when you and others share your JSON configuration on the ToolboxHub [ToolboxRegistry](https://github.com/ToolboxHub/ToolboxRegistry).  The sample-repo is already [there](https://github.com/ToolboxHub/ToolboxRegistry/blob/master/configurations/sample-repo.json).

You can use the convenience utility `tbUse()` to install registered toolboxes by name:
```
tbUse('sample-repo');
which master.txt
```

You should get results like the following:
```
>> tbUse('sample-repo');
Updating "ToolboxRegistry".
Updating "sample-repo".
Adding ToolboxToolbox to path at "/home/ben/ToolboxToolbox".
Adding "sample-repo" to path at "/home/ben/toolboxes/sample-repo".
Looks good: all toolboxes deployed OK.

>> which master.txt
/home/ben/toolboxes/sample-repo/master.txt
```

# Toolbox Records and Types
You can declare toolboxes of several types using the `tbToolboxRecord()` function.  See details at [Toolbox Records and Types](https://github.com/ToolboxHub/ToolboxToolbox/wiki/Toolbox-Records-and-Types).

# Write Your Own Strategy
You can extend the ToolboxToolbox to support additional types of toolbox.  See details at [Custom Toolbox Strategies](https://github.com/ToolboxHub/ToolboxToolbox/wiki/Custom-Toolbox-Strategies).

# Contributing

If you want to contribute your own toolbox configuration to this public registry -- thanks!  Here's how:
 - [Clone](https://help.github.com/articles/fork-a-repo/) the [ToolboxRegistry](https://github.com/ToolboxHub/ToolboxRegistry) repository on GitHub.
 - Commit your JSON configuration file to the `/configurations` folder.
 - Create a [Pull Request](https://help.github.com/articles/creating-a-pull-request-from-a-fork/) from your fork so that we can see your contribution and merge it in.

The same goes for the ToolboxToolbox itself.  Please fork this repository and create pull requests.

