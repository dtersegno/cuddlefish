extends GridContainer


#store the colors of each square for each cuddler number in the solution.
#should be used to set up the puzzle as well
var solution_coloring = {
	'blue': {
		0: [0, 6],
		1: [4, 0],
		2: [4, 5],
		6: [1, 6],
		11: [2, 1],
		7: [5, 6],
		12: [2, 1],
		8: [5, 2],
		3: [6, 0],
		4: [4, 6],
		9: [2, 5],
		13: [1, 0],
		14: [4, 6],
		19: [2, 6],
		24: [2, 3],
		18: [7, 6],
		23: [2, 4],
		22: [0, 2],
		17: [6, 5],
		21: [1, 4],
		20: [0, 1],
		16: [5, 4],
		15: [0, 2],
		10: [6, 2],
		5: [6, 2]},
	'purple': {
		0: [6, 0],
		1: [4, 6],
		6: [2, 5],
		10: [1, 6],
		15: [2, 6],
		20: [2, 0],
		21: [4, 2],
		16: [6, 1],
		12: [5, 7],
		18: [3, 5],
		22: [1, 0],
		23: [4, 0],
		24: [4, 2],
		19: [6, 2],
		14: [6, 2],
		9: [6, 4],
		8: [0, 1],
		4: [5, 4],
		3: [4, 0],
		2: [0, 6],
		7: [2, 7],
		13: [3, 5],
		17: [1, 3],
		11: [7, 3],
		5: [7, 2]},
	'green': {
		0: [7, 0],
		1: [4, 5],
		5: [1, 6],
		10: [2, 0],
		11: [4, 5],
		15: [1, 6],
		20: [2, 0],
		21: [4, 0],
		22: [4, 3],
		16: [7, 0],
		17: [4, 2],
		12: [6, 0],
		13: [4, 7],
		19: [3, 5],
		23: [1, 0],
		24: [4, 3],
		18: [7, 1],
		14: [5, 2],
		9: [6, 2],
		4: [6, 4],
		3: [4, 0],
		2: [0, 7],
		8: [3, 4],
		7: [4, 0],
		6: [0, 3]
	}
}

var swap_plan_p = {
	0:[5,1],
	1:[3,6],
	10:[1,5],
	15:[3,5],
	20:[3,7],
	21:[5,2],
	22:[7,1],
	23:[0,5],
	24:[4,1],
	19:[7,1],
	14:[7,2],
	4:[5,3],
	3:[1,4],
	5:[7,3]
}
var swap_plan_g = {
	0:[2,7],
	1:[2,5],
	5:[1,5],
	10:[3,0],
	15:[1,4],
	20:[6,4],
	21:[0,6],
	24:[3,6],
	23:[6,1],
	14:[1,5],
	9:[1,7],
	4:[7,2],
	3:[2,3],
	2:[2,7]
}


@onready var cuddler_prime = $Cuddler_Prime

var cuddler = preload("res://cuddler2-0.tscn")
var edge_block = preload("res://edge_block.tscn")

#to be filled on creation. Cuddlers and edge blocks are also added to groups, but
#group orders are not guaranteed.
var cuddlers = []
var edge_blocks = []

#visual reference for cuddlegrid
@onready var cuddlegrid_sprite = $CuddlegridNos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# remove the sprite 
	cuddlegrid_sprite.queue_free()
	create_cuddlerows(5,5)
	cuddler_prime.queue_free()
	#for number in range(16):
		#print(str(number) + '%8: ' + str(number%8))
		
	#adjust the default "solution" to include different numbers for parallel edges
	solution_coloring['green'].merge(swap_plan_g, true)
	solution_coloring['purple'].merge(swap_plan_p, true)
		
	self.paint_solution()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		perform_cuddler_comparison()
	if Input.is_action_just_pressed("ui_down"):
		get_tree().call_group('cuddlers','random_spin')
	if Input.is_action_just_pressed("ui_up"):
		check_cuddler_directions()

#cuddlers are created with the solution at direction 0
func check_cuddler_directions():
	#are all the cuddlers checked so far pointing to the right / direction 0.
	var all_right = true
	for cuddler in cuddlers:
		all_right = all_right and (0 == cuddler.direction)
	if all_right:
		print("that's the solution!")
	else:
		print("not correct")
		
func create_cuddlefish(number_to_create:int):
	for new_cuddler_counter in range(number_to_create):
		var new_cuddler = cuddler.instantiate()
		self.add_child(new_cuddler)
		new_cuddler.add_to_group('cuddlers')
		cuddlers.append(new_cuddler)
		new_cuddler.button_clicked.connect(self.perform_cuddler_comparison)
		
#create all the cuddlefish along with edge blocks for a 7x7 grid.
func create_cuddlerows(rows:int, cols:int):
	#add cols+2 children for the top
	create_edge_block(cols + 2, 3) #face down on top row
	for row in range(rows):
		create_edge_block(1, 0) #face right on the left
		create_cuddlefish(cols)
		create_edge_block(1, 2) # face left on the right
	create_edge_block(cols + 2,1) #bottom row
	return null

# create edge blocks with orientations 0, 1, 2, or 3
# these are different than the squares within a cuddlefish.
# sorry for using the same name, sorry. sorry..
func create_edge_block(number_to_create:int, orientation:int):
	for number in range(number_to_create):
		var new_edge_block = edge_block.instantiate()
		self.add_child(new_edge_block)
		new_edge_block.add_to_group('edge_blocks')
		edge_blocks.append(new_edge_block)
	return null

#a dict of colors
var default_colors = {
	'purple':Color('DARK_ORCHID'),
	'orange':Color('DARK_ORANGE'),
	'blue':Color('CORNFLOWER_BLUE'),
	'green':Color('CHARTREUSE'),
	'gray':Color('GRAY'),
	'white':Color('WHITE')
}

func paint_all_squares(color):
	get_tree().call_group('cuddlers','paint_cuddle_colors')

func paint_solution() -> void:
	for color in solution_coloring:
		for cuddler_index in range(len(cuddlers)):
			var color_these_squares = solution_coloring[color][cuddler_index]
			var this_cuddler = cuddlers[cuddler_index]
			for square in color_these_squares:
				this_cuddler.paint_single_square(square, default_colors[color])
				this_cuddler.cuddle_colors[square] = default_colors[color]
	
		
	
# whether the colors at certain positions of
#two cuddlers are the same

# mark which internal squares to compare.
#ex V: [6,2] compares the bottom of the first cuddler
#to the top of the second.
# squares start at 0 at Right, 1 at Upper Right,
# and continue xclockwise to 7 at the Lower Right
# comparison order is important.
var comparisons = {
	#comparisons between cuddlers
	"V":[6,2], #top to bottom
	"H":[0,4], #right to left
	"D1":[7,3], #lower right to upper left
	"D2":[5,1], #lower left to upper right
	"EE_L": [4,4], #both lefts
	"EE_R": [0,0], #both rights
	"EE_U": [2,2], #both tops
	"EE_D": [6,6], #both bottoms
	"EC_L": [5,3], #lower left to upper left
	"EC_R": [7,1], #lower right to upper right
	"EC_U": [1,3], #upper right to upper left
	"EC_D": [7,5], #lower right to lower left
}

#points to pairs of squares in a 5x5 grid,
# [[0..4],[5..9],[10..14],[14..19],[20..24]]
#that the given comparison is applied
var compare_these_cuddlers_25 = {
	"V":[
		[0,5],[1,6],[2,7],[3,8],[4,9],
		[5,10],[6,11],[7,12],[8,13],[9,14],
		[10,15],[11,16],[12,17],[13,18],[14,19],
		[15,20],[16,21],[17,22],[18,23],[19,24]
	],
	"H":[
		[0, 1],
 		[1, 2],
		[2, 3],
		[3, 4],
		[5, 6],
		[6, 7],
		[7, 8],
		[8, 9],
		[10, 11],
		[11, 12],
		[12, 13],
		[13, 14],
		[15, 16],
		[16, 17],
		[17, 18],
		[18, 19],
		[20, 21],
		[21, 22],
		[22, 23],
		[23, 24]
	],
	"D1":[[0, 6],
		 [1, 7],
		 [2, 8],
		 [3, 9],
		 [5, 11],
		 [6, 12],
		 [7, 13],
		 [8, 14],
		 [10, 16],
		 [11, 17],
		 [12, 18],
		 [13, 19],
		 [15, 21],
		 [16, 22],
		 [17, 23],
		 [18, 24]],
	"D2":[
		[1, 5],
		 [2, 6],
		 [3, 7],
		 [4, 8],
		 [6, 10],
		 [7, 11],
		 [8, 12],
		 [9, 13],
		 [11, 15],
		 [12, 16],
		 [13, 17],
		 [14, 18],
		 [16, 20],
		 [17, 21],
		 [18, 22],
		 [19, 23]
		],
	"EC_R":[
		[4,9],
		[9,14],
		[14,19],
		[19,24]
	],
	"EC_U":[
		[0,1],
		[1,2],
		[2,3],
		[3,4]
	],
	"EC_L":[
		[0,5],
		[5,10],
		[10,15],
		[15,20]
	],
	"EC_D":[
		[20, 21],
		[21, 22],
		[22, 23],
		[23, 24]
	],
	"EE_R":[
		[4,9],
		#[9,14],
		#[14,19],
		[19,24]
	],
	"EE_U":[
		[0,1],
		#[1,2],
		#[2,3],
		[3,4]
	],
	"EE_L":[
		[0,5],
		#[5,10],
		#[10,15],
		[15,20]
	],
	"EE_D":[
		[20,21],
		#[21,22],
		#[22,23],
		[23,24]
	]
}

#label edge blocks: 
# top row 0 - 6
# 7, 8
# 9, 10,
# 11, 12,
# 13, 14,
# 15, 16
# 17 - 23
# edge blocks 1, 2 link the cuddlers below via their center-edge squares
# and their shared corners.
# so, if the EE_U (edge cuddler, edge square, upper) comparison between
# cuddlers 0 and 1 is true, these blocks should light up.
# likewise, if the EC_U comparison is true, those should light.
# give the comparison type, receive a list of squares that undergo
# that comparison, and the edge block that cares about it.
var edge_block_comparisons = {
	"EC_R":[
		[
			[4,9],
			[8,10]
		],
		[
			[9,14],
			[10,12]
		],
		[
			[14,19],
			[12,14]
		],
		[
			[19,24],
			[14,16]
		]
	],
	"EC_U":[
		[
			[0,1], # if these cuddlers pass the EC_U check...
			[1,2] # ...light up these edge blocks.
		],
		[
			[1,2], #cuddler nos
			[2,3]  #edge block nos
		],
		[
			[2,3],
			[3,4]
		],
		[
			[3,4],
			[4,5]
		]
	],
	"EC_L":[
		[
			[0,5],
			[7,9]
		],
		[
			[5,10],
			[9,11]
		],
		[
			[10,15],
			[11,13]
		],
		[
			[15,20],
			[13,15]
		]
	],
	"EC_D":[
		[
			[20,21],
			[18,19]
		],
		[
			[21,22],
			[19,20]
		],
		[
			[22,23],
			[20,21]
		],
		[
			[23,24],
			[21,22]
		]
	],
	"EE_R":[
		[
			[4,9],
			[8,10]
		],
		[
			[19,24],
			[14,16]
		]
	],
	"EE_U":[
		[
			[0,1],
			[1,2]
		],
		[
			[3,4],
			[4,5]
		]
	],
	"EE_L":[
		[
			[0,5],
			[7,9]
		],
		[
			[15,20],
			[13,15]
		]
	],
	"EE_D":[
		[
			[20,21],
			[18,19]
		],
		[
			[23,24],
			[21,22]
		]
	]
}

#take two squares and a type of comparison.
#return the result of the comparison.
#ex
#cuddle_compare(<cuddler A>,<cuddler B>, "V")
#compares cuddler A's square 6 to cuddler B's square 2.

# compares all cuddlers and flashes squares as a result
# locks rotation until flashing is done.
func perform_cuddler_comparison() -> void:
	var result = compare_all_cuddlers()
	var all_cuddlers = get_tree().get_nodes_in_group('cuddlers')
	for comparison in result:
		# for each comparison type,
		# get [ [cuddlerA, cuddlerB], true/false ]
		for single_comparison in result[comparison]:
			#if the comparison is true (the colors are the
			#same), flash those cuddlers' squares.
			if single_comparison[1]:
				var cuddlerAindex = single_comparison[0][0]
				var cuddlerBindex = single_comparison[0][1]
				var cuddlerA = all_cuddlers[cuddlerAindex]
				var cuddlerB = all_cuddlers[cuddlerBindex]
				cuddlerA.disable_button()
				cuddlerB.disable_button()
				cuddlerA.flash_square(
					comparisons[comparison][0]
				)
				cuddlerB.flash_square(
					comparisons[comparison][1]
				)
				#print(
					#'Cuddler '
					#+ str(cuddlerAindex)
					#+ ' '
					#+ comparison
					#+ ' Cuddler '
					#+ str(cuddlerBindex)
				#x)

# a single comparison between two cuddlers
func cuddle_compare(cuddler1, cuddler2, comparison) -> bool:
	var square_indices = comparisons[comparison]
	
	#compare the actual assigned color
	#var color1 = cuddler1.edge_blocks[square_indices[0]].color
	#var color2 = cuddler2.edge_blocks[square_indices[1]].color
	
	#compare the record of the color
	var color1 = cuddler1.get_color_of_square(square_indices[0], false)
	var color2 = cuddler2.get_color_of_square(square_indices[1], false)
	
	return color1 == color2
	
# using all comparison types, compares all cuddlers registered
# for each type.
# returns a dictionary like:
# result = {
#    "comparison type 1":[
#		[
#			[cuddlerA, cuddlerB], 
#			true
#		],
#		[
#			[cuddlerB, cuddlerD],
#			false
#		],...
#	],
#	"comparison type 2": ...
#}

#performs the comparisons amongst all cuddlers and returns
#a dict with bools of outcomes. Used by perform_cuddler_comparison()
func compare_all_cuddlers():
	var all_cuddlers = get_tree().get_nodes_in_group('cuddlers')
	var result = {}
	for comparison in comparisons:
		#prepare a report
		var comparison_result = []
		#get the color squares to compare
		var square_pair = comparisons[comparison]
		#var square1 = square_pair[0]
		#var square2 = square_pair[1]
		#get the cuddlers that will have these comparisons
		var cuddlers_to_compare = compare_these_cuddlers_25[comparison]

		for cuddler_pair in cuddlers_to_compare:
			var cuddlerA = all_cuddlers[cuddler_pair[0]]
			var cuddlerB = all_cuddlers[cuddler_pair[1]]
			comparison_result.append(
				[
					[
						cuddler_pair[0],
						cuddler_pair[1]
					],
					cuddle_compare(
						cuddlerA,
						cuddlerB,
						comparison
					)
				]
			)
		result.merge({comparison:comparison_result})
		
	return result
	
