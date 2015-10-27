computercraft-programs
======================

Lua scripts for computercraft, dan200's minecraft mod. 

## The Turtle Apps
So far, all the focus of this work has been for the robot; you can find the programs and other useful files under the turtleApps/src directory.

Script farm.lua is there to plant and harvest the basic food crops.

The sortAndBlock.lua script is for quickly making blocks from a mix of blockable
and non-blockable items.

<TODO> Obby Miner: 

## The Operation Manuals, Launchers, Test Stubs and Harnesses

Each of the completed programs has its own help document in markdown format: farmHowTo.md, obbyMinerHowTo.md <TODO> and sortAndBlockHowTo.md

There's a launcher called startup.lua, so that a player might launch a turtle program with a button-click or by opening a trapped chest.

Test harnesses include testFarm.lua and testMockTurtle, to help unit test the programs within eclipse instead of launching the Minecraft client.

mockTurtle.lua is a "stub" for the test harnesses.