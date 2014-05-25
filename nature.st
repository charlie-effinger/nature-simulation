"Charles Effinger"
"CS 450 Program 3 - Smalltalk"

" Declare the global variables to represent the seed for Animal IDs and the 
  seed for the Random Number Generator. "
| AnimalSeed  RandSeed |

" The Animal class represents an animal in a simulated nature reserve. "
Object subclass: #Animal .
Animal instanceVariableNames: ' id row col dir oldCell newCell litterSize age 
								       maxAge' .
Animal comment: 'I represent a simulation of an animal' .

Animal class extend [
"If no information is given when the animal is created, all values are 
 initialized to zero. "
	new [
		^ super new init: 0 inCol: 0 inDir: 0 inAge: 0 
	] 
	new: row col: col dir: dir age: age [
		^ super new init: row inCol: col inDir: dir inAge: age
	]
"If no age is given, then the animal is assumed to have just been born. "	
	new: row col: col dir: dir[
		^ super new init: row inCol: col inDir: dir inAge: 0
	]
]  

Animal extend [
	init: inRow inCol: inCol inDir: inDir inAge: inAge[
		(AnimalSeed = nil) ifTrue:[AnimalSeed := 0].
		col := inCol .
		row := inRow .
		dir := inDir .
		age := inAge.
		id := AnimalSeed .
		AnimalSeed := AnimalSeed + 1. 	
" If the random seed has not been initialized, initialize it. "		
		(RandSeed = nil) ifTrue:[RandSeed := Random new].
	]
]

Animal extend [
	getID [ ^ id  ]
" 'id' has no setter since it is unique and depends on the Animal Seed. "	
	
	getRow [ ^ row ]
	setRow: newRow [ row := newRow . ]
	
	getCol [ ^ col ]
	setCol: newCol [ col := newCol . ]
	
	getDirection [^ dir ]
	setDirection: newDir [ dir := newDir . ]
	
" The new and old cells are used for the Animal's act function. The contents 
  of the cell determine how the animal acts. "
	setCells: nCell oldCell: oCell [
		newCell := nCell . "The new cell comes from the new grid."
		oldCell := oCell . "The old cell comes from the current grid. "
	]
	getOldCell [ ^ oldCell ]
	getNewCell [ ^ newCell ]
	
" The base act procedure for animal assumes that the animal has survived the 
  current month. Thus, a new direction is selected for the animal and the animal
  is placed into the new cell. " 
	act [ 
		self setDirection: (RandSeed between: 1 and: 4).
		age := age + 1.
		newCell place: self . 
" After the animal has moved, the carrying capacity of its new cell is checked.
  If it is over capacity, the animal will die along with any others that are 
  over capacity. " 		
		newCell checkCarryingCapacity . " *EXTRA CREDIT* "
	]
	
" This procedure will birth 'litterSize' amount of the type of animal given and
  place them into the new cell. "
	birthAnimals [
		| index animal |
		index := 1 .
		[index <= litterSize]
		whileTrue: [
			animal := (self class) new: row col: col dir: 
					  (RandSeed between: 1 and: 4) .
			newCell place: animal .
			index := index + 1 .
		]. 
	]
		 
] 

" Lynx is a subclass of Animal that represents the predator of 
  the nature reserve. "
Animal subclass: #Lynx .
Lynx comment: 'I represent a simulation of a Lynx animal.' .

Lynx extend [
	init: inRow inCol: inCol inDir: inDir inAge: inAge [ 
		litterSize := 1 . "Lynx can only have one baby at a time. "
		maxAge := 12. "Lynx cannot live longer than 12 months. "
		^ super init: inRow inCol: inCol inDir: inDir inAge: inAge
	]
]

Lynx extend [
	act [
" If the Lynx is over a year old, let it die. "		
		(age < maxAge)  " *EXTRA CREDIT* "
		ifTrue:[
" Check the current grid cell for food. "			
			(oldCell getNumRabbits > 0)
			ifTrue: [  
				oldCell remove: Rabbit . "Eat a rabbit."
				self birthAnimals. "Make a baby. "
				^ super act 
			] .
"Check the old grid cell for food. "			
			(newCell getNumRabbits > 0)
			ifTrue: [	
				newCell remove: Rabbit . "Eat a rabbit. "
				self birthAnimals. "Make a baby. "
				^ super act
			] .
		]	
" The only way the procedure reaches here is if the Lynx is too old or if the 
  Lynx didn't find any food. Therefore, it dies as the base Animal class
  procedure act isn't invoked. "	
	]
]

" The Rabbit subclass of Animal represents the prey of the nature reserve. "
Animal subclass: #Rabbit .
Rabbit comment: 'I represent a simulation of a Rabbit animal.' .

Rabbit extend [
	init: inRow inCol: inCol inDir: inDir inAge: inAge[
		litterSize := 5 . " Rabbits have 5 babies at a time. "
		maxAge := 5. " Rabbits cannot live longer than 5 months. " 
		^ super init: inRow inCol: inCol inDir: inDir inAge: inAge
	]
]

Rabbit extend [
	act [
" If the rabbit is over 5 months old, let it die,"		
		(age < maxAge) " *EXTRA CREDIT* "
		ifTrue:[
" Check the current and new grid cells for other rabbits and make sure that the
  rabbit is not a baby. "			
			(((oldCell getNumRabbits > 0) | 
			  (newCell getNumRabbits > 0)) & (age > 0))	
			ifTrue: [  
				self birthAnimals . " Make some babies. "	
			] .
		^ super act  
		]
" If the rabbit is too old, it will not call Animal's act and die. "	
	]
]

" The Cell object represents an individual cell of the nature reserve. "
Object subclass: #Cell .
Cell instanceVariableNames: ' rabbits lynxes maxRabbit maxLynx ' .
Cell comment: 'I represent an individual cell in the nature reserve grid. ' .

Cell class extend [
	new [
		^ super new init
	]
]

Cell extend [
	init [ 
" The rabbits and lynxes of the cell are kept in OrderedCollection objects. 
  This allows them to be dynamically added and removed, without worrying about
  indexing issues. "		
		rabbits := OrderedCollection new .
		lynxes := OrderedCollection new .
			
		maxRabbit := 400. " The carrying capacity of rabbits is 400. "
		maxLynx := 40. " The carrying capacity of lynxes is 40. "
	]

" These getters return the number of animals in the cell. "	
        getNumLynxes [ ^ lynxes size ] 
		getNumRabbits [ ^ rabbits size	] 		
	
" The last animal in the collection is always chosen when a query is made for
  one. Thus, they are LIFO structures. "	
	getRabbit [ ^ rabbits last ]
	getLynx [ ^ lynxes last ]
	
" This procedure checks to make sure the carrying capacity hasn't been 
  violated. If it has been, it restores equilibrium by killing off the last 
  animals to enter the cell. "	
	checkCarryingCapacity [
		[self getNumRabbits > maxRabbit]
		whileTrue: [self remove: Rabbit].
		
		[self getNumLynxes > maxLynx]
		whileTrue: [self remove: Lynx].
	]
	
" This procedure will add the given animal to the cell. "
	place: animal [
" The species of the animal is checked and added to the correct collection. "		
		(animal class = Lynx) 
			ifTrue: [ lynxes add: animal ]
			ifFalse: [ rabbits add: animal ].
	]
" This procedure will remove an animal of the given species from the cell. It 
  makes sure at least one of the animals is in the cell, then removes the last
  animal to enter the cell. "	
	remove: animal [
		(animal = Lynx)
		ifTrue: [ (lynxes size > 0)  
			ifTrue: [
				lynxes removeLast 
			]
		] ifFalse: [ (rabbits size > 0)
			ifTrue: [
				rabbits removeLast 
			]
		].
	]
]

" The Grid object represents the nature reserve as an array of an array of 
  cells. "
Object subclass: #Grid .
Grid class instanceVariableNames: 'maxLength' .
Grid instanceVariableNames: 'cells length' .
Grid comment: 'I represent a 10x10 grid that simulates a nature reserve.' .

Grid class extend [
	initialize [
		maxLength := 10. "The default size of the grid is 10x10. "
	]
	new [
		self initialize .
		^ super new init: maxLength	
	]
" A different size grid can be specified with a single parameter with new. "	
	new: length [
		^ super new init: length 
	]
]

Grid extend [
	init: gridLength [
		| rowIndex colIndex |
		length := gridLength .
		rowIndex := 1 .
		
		cells := Array new: length .
" Iterate through the rows of the grid. "		
		[rowIndex <= length] 
		whileTrue: 
		[
			| newCells |
" Each row of the grid has an array to hold the values of the columns. "			
			newCells := Array new: length .
			cells at: rowIndex put: newCells .
			
			colIndex := 1 .
" Iterate through the columns of the grid. "			
			[colIndex <= length] 
			whileTrue: 
			[
				| tmpCell |
" Place a new cell into each row-column spot. "				
				tmpCell := Cell new .
				(cells at: rowIndex) at: colIndex put: tmpCell .
				colIndex := colIndex + 1 .
			] .
			rowIndex := rowIndex + 1 . 
		] .	
" If the Random Number Generator has not been seeded yet, seed it. "		
		(RandSeed = nil) ifTrue:[RandSeed := Random new].
	]
]

Grid extend [
	
	getCellAtRow: row col: col [ ^ ((cells at: row) at: col) . ]
	setCellAtRow: row col: col cell: cell [
		(cells at: row) at: col put: cell .
	] 

" These getters return the number of animals at the given cell. "	
	getLynxesAtRow: row col: col [ 
		^ ((self getCellAtRow: row col: col) getNumLynxes) 
	]
	getRabbitsAtRow: row col: col [
		^ ((self getCellAtRow: row col: col) getNumRabbits)
	]
" This procedure places the given animal into the given cell by calling the 
  given cell's place procedure. "	
	place: animal row: row col: col [
" Update the row and column of the animal before inserting for consistency. "		
		animal setRow: row .
		animal setCol: col .
		(self getCellAtRow: row col: col) place: animal .
	] 

" This procedure removes an animal of the same species given from the given 
  cell by calling the cell's remove procedure. "	
	remove: animal row: row col: col [
		(self getCellAtRow: row col: col) remove: (animal class) .
	]	
	
	getLength [ ^ length ]
]

" The Simulation class can run a monthly simulation of a nature reserve. "
Object subclass: #Simulation .
Simulation class instanceVariableNames: 'defaultRabbitNum defaultLynxNum' .
Simulation instanceVariableNames: 'month rabbitNum lynxNum currentGrid newGrid'.
Simulation comment: 'I represent a simulation of a nature reserve' .

Simulation class extend [
	initialize [	
" The default number of rabbits and lynxes is used unless otherwise specified."		
		defaultRabbitNum := 50.
		defaultLynxNum := 10.
	]
	new [
		(defaultRabbitNum = nil) ifTrue: [self initialize] .
		^ super new init: defaultRabbitNum numLynxes: defaultLynxNum	
	]
" A different number of rabbits and lynxes can be used if specified with two 
  parameters with new. "	
	new: rabbits numLynxes: lynxes [
		^ super new init: rabbits numLynxes: lynxes 
	]
]

Simulation extend [
	init: numRabbits numLynxes: numLynxes [
		rabbitNum := numRabbits .
		lynxNum := numLynxes .
		month := 0 . " On initialization, no months have passed. " 
	]
]

Simulation extend [
" This procedure will initialize the animals of the simulation. "	
	setup [
		currentGrid := Grid new .
		self initAnimals: (Rabbit) .
		self initAnimals: (Lynx) .
	]
	
" This procedure will initialize the animals of the given species for the
  simulation. "  	
	initAnimals: currAnimal [
		| index num length row col dir animal age |
		length := currentGrid getLength .
		(currAnimal = Lynx) ifTrue: [ num := lynxNum . ]
			                  ifFalse: [ num := rabbitNum . ] .
		index := 1 .
		[index <= num] 
		whileTrue: [
" Random initialize the age, row, column, and direction of the animal. "			
" Age is between 1 and 4 so that every animal is mature enough to reproduce. "			
			age := RandSeed between: 1 and: 4.
			row := RandSeed between: 1 and: length .
			col := RandSeed between: 1 and: length .
			dir := RandSeed between: 1 and: 4 .
			animal := currAnimal new: row col: col dir: dir age: 
 									 age.
			currentGrid place: animal row: row col: col .
			index := index + 1 .
		] .
	]

" These procedures were used for debugging. "
	getCurrGrid [ ^ currentGrid ]
	getNewGrid [ ^ newGrid ]	

" This procedure will simulate a month of the nature reserve. "	
	step [
		| rowIndex colIndex currCell newCell newCol newRow animal 
		 length oldCell |
		length := currentGrid getLength .
" Create a new grid to populate as the animals move and act. "		
		newGrid := Grid new: length .

" NOTE: Spaces were use instead of tabs for readability. "
		
		rowIndex := 1 .
" Iterate through all the rows of the grid. "		
		[rowIndex <= length] 
		whileTrue: [
		  colIndex := 1 .
" Iterate through all the columns of the grid. "  
		  [colIndex <= length] 
		  whileTrue: [
" Get the current cell that will be simulated. "		    
		    currCell := currentGrid getCellAtRow: rowIndex col: 
								       colIndex.		
" Check to see if there are any animals left in the current cell. "		    
		    [(currCell getNumRabbits > 0) | ((currCell getNumLynxes) 
									   > 0)] 
		    whileTrue: [
" If there are still lynxes left in the cell, let them act first. Otherwise, let
  the rabbits act. Animals are grabbed from the back of the collection. "		      
		      ((currCell getNumLynxes) > 0) 
		      ifTrue: [ animal := currCell getLynx ] 
		      ifFalse: [ animal := currCell getRabbit ] .		
" Since the getRabbit/getLynx procedure grabs the last animal from the 
  collection, a simple remove of the animal species will delete the current  
  animal from the collection . "   
		      currCell remove: (animal class) .
		
" The following block moves the animal. Directions 1,2,3,4 correspond to north,
  east, south, west or up, right, down, left. "			

" NOTE: The calculations were reduced for space purposes. Originally, they read:
  		(index +/- 1 + length - 1 mod length) + 1
  The +/- 1 operation represents the movement up/down or left/right. 
  The + length - 1 operation ensures that the modulus will not give a negative 
  remainder. 
  The mod length + 1 operation ensures the answer will be correct and between
  the min and max bounds (1 and length) of the grid. This also ensures that 
  adding 1 to 10 results in 1 and subtracting 1 from 1 results in 10. "   	      
" Example Calc: 10 + 1 + 10 - 1 = 20 mod 10 = 0 + 1 = 1. "	
		      (animal getDirection = 1) 
		      ifTrue: [
			    animal setRow: (((rowIndex+length-2) rem: length)+1)  
		      ] ifFalse: [
			    (animal getDirection = 2) 
			     ifTrue: [
			       animal setCol: (((colIndex+length) rem: length)+1) 
			     ] ifFalse: [
			       (animal getDirection = 3) 
			        ifTrue: [
			        animal setRow: (((rowIndex+length) rem:length)+1) 
			        ] ifFalse: [
		    	      animal setCol: (((colIndex+length-2) rem:length)+1) 
			        ]
			     ]
		      ] .
		
" Once the animal has moved, get its new coordinates. "		      
		      newCol := animal getCol .
		      newRow := animal getRow .
" Give the animal the cell from the current grid and from the new grid so it can
  correctly decide what is should do. "     
	          oldCell := currentGrid getCellAtRow: newRow col: newCol .
		      newCell := newGrid getCellAtRow: newRow col: newCol . 
		      animal setCells: newCell oldCell: oldCell .
			
		      animal act .			
" Update the cells in the current and new grids to reflect what the animal just
  did. "		      
  		      currentGrid setCellAtRow: newRow col: newCol cell: 
							   (animal getOldCell) .
		      newGrid setCellAtRow: newRow col: newCol cell: 
							   (animal getNewCell) .			          
		  ] .
" Once this point has been reached, then the current cell has had every animal
  act and is empty. Update the current grid to reflect this emptiness. "		  
		  currentGrid setCellAtRow: rowIndex col: colIndex cell: 
								      currCell .
		  colIndex := colIndex + 1.
		] .
		rowIndex := rowIndex + 1 .	
					
		] .
" Every animal has acted for the month once this point is reached. 
  The current grid is now empty and needs to be set to the new grid to reflect
  the changes that occurred during the month. "		
		currentGrid := newGrid .
		month := month + 1. 
	]

" This procedure will print the current status of the nature reserve. "	
	status [
		| rowIndex colIndex rCount lCount |
		'month: ' print .
			month printNl.
		rowIndex := 1 .
" These counters are used to calculate the total number of each type of animal
  in the nature reserve. "		
		rCount := 0 .
		lCount := 0 .

" Iterate through every cell. "		
		[rowIndex <= (currentGrid getLength)] 
		whileTrue: [
		  colIndex := 1 .
		  
		  [colIndex <= (currentGrid getLength)] 
		  whileTrue: [
" Display each row, and number of animals that exist in that cell. "		      
		      'row: ' print .
		      rowIndex print .
    		      ' col: ' print .
		      colIndex print .
		      ' rabbits: ' print .	
		      (currentGrid getRabbitsAtRow: rowIndex col: colIndex) 
								    print .
		      ' lynxes: ' print .
		      (currentGrid getLynxesAtRow: rowIndex col: colIndex) 
								    printNl .
		      
		      rCount := rCount + (currentGrid getRabbitsAtRow: rowIndex 
								col: colIndex) .
		      lCount := lCount + (currentGrid getLynxesAtRow: rowIndex 
								col: colIndex) .
		      colIndex := colIndex + 1.
		  ] .
		  rowIndex := rowIndex + 1 .
		] .
" Display the total amount of animals in the nature reserve. "		
		'Total Rabbits: ' print .
		rCount print .
		' Total Lynxes: ' print .
		lCount printNl .
	
	]
]	
