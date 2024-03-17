extends Node2D

@onready var sub_1 = $"../Substance1".sub
@onready var sub_2 = $"../Substance2"

var size = Vector2(0, 0)

var new_sub: Dictionary

func get_size():
	return size

func update_new_sub():
	new_sub = sub_1.duplicate(true)
	new_sub.with_question = false

func reaction():
	update_new_sub()
	
	if sub_2.type == "O2":
		combustion_reaction()
	
	match sub_1.type:
		"Alkane":
			match sub_2.type:
				"H2", "Na", "HCl", "H2O":
					not_react()
				"Cl2":
					halogenation_reaction() #возможа вариативость
			
		"Alkene":
			match sub_2.type:
				"H2":
					hydrogenation_reaction()
				"Cl2":
					halogenation_reaction()
				"Na":
					not_react()
				"HCl":
					hydrohalogenation_reaction()
				"H2O":
					hydration_reaction()
		"Alkyne":
			match sub_2.type:
				"H2":
					hydrogenation_reaction()
				"Cl2":
					halogenation_reaction()
				"Na":
					not_react()
				"HCl":
					hydrohalogenation_reaction()
				"H2O":
					hydration_reaction()
		"Cycloalkane":
			match sub_2.type:
				"H2":
					if sub_1.length < 5:
						cycloalkane_to_alkane() #!!
					else:
						not_react()
				"Cl2":
					halogenation_reaction()
				"Na":
					not_react()
				"HCl":
					not_react()
				"H2O":
					not_react()
		"Benzene":
			match sub_2.type:
				"H2":
					set_cyclohexane()
				"Cl2":
					halogenation_reaction()
				"Na":
					not_react()
				"HCl":
					not_react()
				"H2O":
					not_react()
		"Alcohol":
			match sub_2.type:
				"H2":
					not_react()
				"Cl2":
					not_react()
				"Na":
					alcohol_with_alkali_metals()
				"HCl":
					not_react()
				"H2O":
					not_react()
		"Ketone":
			match sub_2.type:
				"H2":
					hydrogenation_reaction()
				"Cl2":
					not_react()
				"Na":
					not_react()
				"HCl":
					not_react()
				"H2O":
					not_react()
		"Aldehyde":
			match sub_2.type:
				"H2":
					hydrogenation_reaction()
				"Cl2":
					not_react()
				"Na":
					not_react()
				"HCl":
					not_react()
				"H2O":
					not_react()
	
	Name.set_element_name(new_sub)

################
#Молекулы, знаки
################

func set_molecule(text, pos):
	var molecule = G.s_molecule.instantiate()
	molecule.position = pos
	if text == "∅":
		molecule.position.y += 4 #знак пустого множества немного сдвинут вверх
	molecule.get_node("Label").text = text
	add_child(molecule)

func set_connection(pos, rot, ammount):
	var connection = G.s_connection.instantiate()
	connection.position = pos
	connection.rotation = rot
	connection.set_lines(ammount)
	add_child(connection)

func set_symbol(text, pos):
	var symbol = G.s_symbol.instantiate()
	symbol.position = pos
	symbol.get_node("Label").text = text
	add_child(symbol)

#############
#Типы реакций
#############

func add_radical(sub, value, number_of_connections, pos):
	var side = 0
	if new_sub.radicals[pos][0] == null:
		side = 0
	elif new_sub.radicals[pos][1] == null:
		side = 1
	
	sub.radicals[pos][side] = {
		"value": value,
		"number_of_connections": number_of_connections
	}


func not_react():
	new_sub = {
		"type": "EmptySet",
		"length": 0, "double_place": 0, "radicals": [],
		"add_distance_r": 0, "add_distance_l": 0,
		"with_question": false,
		"r": 0, "r2": 0, "angle": 0, "h": 0, "h2": 0
	}
	
	size = Vector2(40, 0)
	set_molecule("∅", Vector2(20, 0))

func combustion_reaction():
	size = Vector2(120, 0)
	set_molecule("CO" + G.indexs[2], Vector2(20, 0))
	set_symbol("+", Vector2(60, 0))
	set_molecule("H" + G.indexs[2] + "O", Vector2(100, 0))
	
	for i in range(len(new_sub.radicals)):
		for j in range(len(new_sub.radicals[i])):
			var radical = new_sub.radicals[i][j]
			if radical != null and radical.value == "Cl":
				set_symbol("+", Vector2(140, 0))
				set_molecule("Cl" + G.indexs[2], Vector2(180, 0))
				size.x += 80
	
	new_sub = {
		"type": "EmptySet",
		"length": 0, "double_place": 0, "radicals": [],
		"add_distance_r": 0, "add_distance_l": 0,
		"with_question": false,
		"r": 0, "r2": 0, "angle": 0, "h": 0, "h2": 0
	}

func hydrogenation_reaction():
	if new_sub.type == "Alkene":
		new_sub.type = "Alkane"
		
		size = G.update_size(new_sub)
		G.create_substance(self, new_sub)
	
	elif new_sub.type == "Alkyne":
		new_sub.type = "Alkene"
		
		size = G.update_size(new_sub)
		G.create_substance(self, new_sub)
	
	elif new_sub.type == "Ketone" or new_sub.type == "Aldehyde":
		for i in range(len(new_sub.radicals)):
			for j in range(len(new_sub.radicals[i])):
				var radical = new_sub.radicals[i][j]
				if radical != null and radical.value == "O":
					new_sub.type = "Alcohol"
					new_sub.radicals[i][j] = {
						"value": "OH",
						"number_of_connections": 1
					}
		
		
		size = G.update_size(new_sub)
		G.create_substance(self, new_sub)

func halogenation_reaction():
	match new_sub.type:
		"Alkane", "Cycloalkane":
			var min_hydrogen = 4
			var min_hydrogen_pos = -1
			var side = 0
			
			for i in range(new_sub.length):
				var hydrogen = G.count_hydrogen(new_sub, i)
				if hydrogen < min_hydrogen and hydrogen != 0:
					min_hydrogen = hydrogen
					min_hydrogen_pos = i
			
			if new_sub.radicals[min_hydrogen_pos][0] == null:
				side = 0
			elif new_sub.radicals[min_hydrogen_pos][1] == null:
				side = 1
			elif min_hydrogen_pos == 0 or min_hydrogen_pos == new_sub.length - 1:
				side = 2
			else:
				not_react()
				return
			
			new_sub.radicals[min_hydrogen_pos][side] = {
				"value": "Cl",
				"number_of_connections": 1
			}
			
			size = G.update_size(new_sub)
			
			G.create_substance(self, new_sub)
			
			set_symbol("+", Vector2(size.x + 20, 0))
			set_molecule("HCl", Vector2(size.x + 60, 0))
			
			size.x += 80
		
		"Alkene", "Alkyne":
			if new_sub.type == "Alkene": new_sub.type = "Alkane"
			elif new_sub.type == "Alkyne": new_sub.type = "Alkene"
			
			for i in range(-1, 1):
				var side = 0
				if new_sub.radicals[new_sub.double_place + i][0] == null:
					side = 0
				elif new_sub.radicals[new_sub.double_place + i][1] == null:
					side = 1
				
				new_sub.radicals[new_sub.double_place + i][side] = {
					"value": "Cl", "number_of_connections": 1
				}
			
			size = G.update_size(new_sub)
			G.create_substance(self, new_sub)
		
		"Benzene":
			new_sub.type = "Cycloalkane"
			for i in range(6):
				new_sub.radicals[i].append(
					{"value": "Cl", "number_of_connections": 1}
				)
			
			size = G.update_size(new_sub)
			G.create_substance(self, new_sub)

func hydrohalogenation_reaction():
	if new_sub.type == "Alkene": new_sub.type = "Alkane"
	elif new_sub.type == "Alkyne": new_sub.type = "Alkene"
	
	if G.count_hydrogen(new_sub, new_sub.double_place - 1) <\
		G.count_hydrogen(new_sub, new_sub.double_place):
			add_radical(new_sub, "Cl", 1, new_sub.double_place - 1)
	else:
		add_radical(new_sub, "Cl", 1, new_sub.double_place)
	
	size = G.update_size(new_sub)
	G.create_substance(self, new_sub)

func hydration_reaction():
	var value = ""
	var number_of_connections = 0
	
	if new_sub.type == "Alkene":
		new_sub.type = "Alcohol"
		value = "OH"
		number_of_connections = 1
	
	elif new_sub.type == "Alkyne":
		new_sub.type = "Ketone"
		value = "O"
		number_of_connections = 2
	
	if G.count_hydrogen(new_sub, new_sub.double_place - 1) <\
		G.count_hydrogen(new_sub, new_sub.double_place):
			add_radical(new_sub, value, number_of_connections, new_sub.double_place - 1)
	else:
		add_radical(new_sub, value, number_of_connections, new_sub.double_place)
	
	size = G.update_size(new_sub)
	G.create_substance(self, new_sub)

func cycloalkane_to_alkane():
	new_sub.type = "Alkane"
	new_sub.radicals[0].append(null)
	new_sub.radicals[new_sub.length - 1].append(null)
	
	size = G.update_size(new_sub)
	G.create_substance(self, new_sub)

func alcohol_with_alkali_metals():
	for i in range(len(new_sub.radicals)):
		for j in range(len(new_sub.radicals[i])):
			var radical = new_sub.radicals[i][j]
			if radical != null and radical.value == "OH":
				new_sub.radicals[i][j].value = "ONa"
	
	size = G.update_size(new_sub)
	G.create_substance(self, new_sub)
	
	set_symbol("+", Vector2(size.x + 20, 0))
	size.x += 40
	set_molecule("H" + G.indexs[2], Vector2(size.x + 20, 0))
	size.x += 40

func set_cyclohexane():
	new_sub.type = "Cycloalkane"
	for i in range(6):
		new_sub.radicals[i].append(null)
	
	size = G.update_size(new_sub)
	G.create_substance(self, new_sub)

#############
#Удалить в-во
#############

func remove():
	for i in get_children():
		remove_child(i)
