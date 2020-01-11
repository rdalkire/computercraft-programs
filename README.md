computercraft-programs
======================

These are nested eclipse Lua Development Tools (LDT) projects, to create scripts for what was originally [ComputerCraft](https://github.com/dan200/ComputerCraft), dan200's minecraft mod, often referred-to as "CC".  

However, to use these scripts with more recent versions of minecraft (1.14 at the time of this edit), I would recommend you use SquidDev's fork of the mod, [CC-Tweaked](https://github.com/SquidDev-CC/CC-Tweaked) instead. 

## The Turtle Apps
So far, all the focus of this work has been for the robot; you can find the programs and other files under the turtleApps/src directory, for food-farming, block-making, vein- (and tree) mining
and obby-making.

Latest:  See turtleApps/deploy/saferWallCompiled.lua, which makes high walls and deep pits safe to climb by placing torches and ladders.  Options and usage details provided when you run the program without arguments or with only -h for help.  Thanks again to [Admicos](https://github.com/Admicos) for their argument parser, getOpt

## The Operation Manuals, Launchers, Test Stubs and Harnesses

You can use the "getMy" script to pull other scripts with less typing; for example once you download that with...
 
```
wget https://raw.githubusercontent.com/rdalkire/computercraft-programs/master/turtleApps/src/getMy.lua
```

...then you can simply type like `getMy obbyMiner2` to get other scripts.

Some of the completed programs had their own help documents in markdown format: farmHowTo.md, and sortAndBlockHowTo.md.  I wrote those before I started using getopt.

There's a launcher called startup.lua, so that a player might launch a turtle program with a button-click or by opening a trapped chest.

Test harnesses include testFarm.lua and testMockTurtle, so you can do something like unit tests and debugging in Eclipse before migrating code to your Minecraft client.

mockTurtle.lua is a "stub" for the test harnesses.  
