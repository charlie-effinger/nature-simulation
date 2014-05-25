Overview and Use:

The Smalltalk program 'nature' allows a user to create and simulate a nature
reserve of rabbits and lynxes. The program, when prompted, will create a 
10x10 grid of 'cells' where rabbits and lynxes exist. Then, a monthly simulation
of the reserve can be executed by the user. During this simulation, every animal
will activate. Activation consists of the animal moving in a random direction, 
checking the contents of its new cell, and acting accordingly. If a rabbit moves
into a cell where another rabbit exists, 5 baby rabbits will be born. If there 
are no rabbits, then nothing will happen. If a lynx moves into a cell where at 
least one rabbit exists, it will eat one of the rabbits and make a baby lynx. If
no rabbits exist in the cell where the lynx moves, then the lynx will die. 
A rabbit that is older than 5 months old or a lynx that is older than 12 months
old will die. (EXTRA CREDIT) The maximum carrying capacity of a cell is 400 
rabbits and 40 lynxes. If a cell is over capacity, then the most recent animals
to enter the cell will die until it is no longer over capacity. (EXTRA CREDIT)
At any time during the simulation the user can query the contents of the nature
reserve. The information that is printed out is each cell's row, column and
the number of rabbits and lynxes in the cell. The total number of rabbits and
lynxes is also printed out. The simulation will continue to exist unless it 
is exited or overwritten.

Compilation and Running Instructions:

The nature program must be compiled in a Unix environment. The user must invoke
GNU Smalltalk before running the nature program. This can be done by issuing the
following command while in the same directory as this README file.
	
	gst -q

Once the Smalltalk environment has been invoked, the nature program can be
loaded by issuing the following command:

	(FileStream open:'nature.st' mode:'r') fileIn . !

Once the program has been loaded, a new simulation 'sim' can be created with the
following command:

	sim := Simulation new.

The simulation 'sim' can be initialized for a 10x10 nature reserve with 50
rabbits and 10 lynxes with the following command:

	sim setup.

The simulation 'sim' can simulate a month of the nature reserve with following
command:
	
	sim step.

The simulation 'sim' can print the contents of the nature reserve at any time 
after 'setup' with the following command:

	sim status.

The GNU Smalltalk environment can be exited by issuing a 'control-d' command. 
