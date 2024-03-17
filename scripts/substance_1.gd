extends Node2D

var size = Vector2(0, 0)

var sub = {
	"type": "None",
	"length": 0,
	"double_place": 0,
	"radicals": [],
	
	"add_distance_r": 0,
	"add_distance_l": 0,
	
	"with_question": true,
	
	#параметры для цикловеществ
	"r": 0,
	"r2": 0,
	"angle": 0,
	"h": 0,
	"h2": 0
}

func get_size():
	return size

func create_new_radicals_array():
	sub.radicals = []
	
	for i in range(sub.length):
		sub.radicals.append([])
		sub.radicals[i].append(null)
		
		if sub.type == "Alkane" or sub.type == "Alkene" or sub.type == "Alkyne"\
			or sub.type == "Alcohol" or sub.type == "Ketone" or sub.type == "Cycloalkane":
				sub.radicals[i].append(null)
	
	if sub.type == "Alkane" or sub.type == "Alkene" or sub.type == "Alkyne"\
		or sub.type == "Alcohol" or sub.type == "Ketone":
			sub.radicals[0].append(null)
			sub.radicals[sub.length - 1].append(null)

func set_substance(new):
	if new == true:
		create_new_radicals_array()
	
	size = G.update_size(sub)
	
	G.create_substance(self, sub)
	if sub.with_question == true:
		G.set_questions(self, sub)
	
	if G.substance_2_exists == false:
		Name.set_element_name(sub)

################
#Молекулы, связи
################

func set_molecule(text, pos):
	var molecule = G.s_molecule.instantiate()
	molecule.position = pos
	molecule.get_node("Label").text = text
	add_child(molecule)

func set_connection(pos, rot, ammount):
	var connection = G.s_connection.instantiate()
	connection.position = pos
	connection.rotation = rot
	connection.set_lines(ammount)
	add_child(connection)

func set_question(pos, side):
	var question = G.s_question.instantiate()
	question.position = pos
	question.side = side
	add_child(question)

#################
#Добавить радикал
#################

func add_radical(pos, value, side, number_of_connections):
	sub.radicals[pos][side] = {
		"value": value,
		"number_of_connections": number_of_connections
	}
	
	remove()
	set_substance(false)
	get_parent().update_position()
	
	if G.substance_2_exists == true:
		get_parent().answer()

#############
#Удалить в-во
#############

func remove():
	Name.remove_element_name()
	for i in get_children():
		remove_child(i)
