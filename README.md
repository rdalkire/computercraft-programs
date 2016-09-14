computercraft-programs
======================

These are nested eclipse Lua Development Tools (LDT) projects, to create scripts for [computercraft](http://www.computercraft.info/), dan200's minecraft mod. 

## The Turtle Apps
So far, all the focus of this work has been for the robot; you can find the programs and other files under the turtleApps/src directory, for food-farming, block-making
and obby-making.

Latest:  See turtleApps/deploy/saferWallCompiled.lua, which makes high walls and deep pits safe to climb by placing torches and ladders.  Options and usage details provided when you run the program without arguments or with only -h for help.

## The Operation Manuals, Launchers, Test Stubs and Harnesses

Most of the completed programs have their own help documents in markdown format: farmHowTo.md, obbyMinerHowTo.md and sortAndBlockHowTo.md

An exception is the vein miner program, at turtleApps/deploy/veinMinerCompiled.lua, which is so simple to use that I didn't feel it necessary to have a separate file for instructions.  Instead simply edit the script file itself if you don't know how to use it already.

There's a launcher called startup.lua, so that a player might launch a turtle program with a button-click or by opening a trapped chest.

Test harnesses include testFarm.lua and testMockTurtle, so you can unit test and debug before migrating code to your Minecraft client.

mockTurtle.lua is a "stub" for the test harnesses.  
