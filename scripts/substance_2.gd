extends Node2D

var type: String = "None"

func get_size():
	return Vector2(40 * (2 - 1), 0)

func set_substance():
	var molecule = G.s_molecule.instantiate()
	molecule.position = Vector2(20, 0)
	
	match type:
		"H2":
			molecule.get_node("Label").text = "H" + G.indexs[2]
		"O2":
			molecule.get_node("Label").text = "O" + G.indexs[2]
		"Cl2":
			molecule.get_node("Label").text = "Cl" + G.indexs[2]
		"Na":
			molecule.get_node("Label").text = "Na"
		"HCl":
			molecule.get_node("Label").text = "HCl"
		"H2O":
			molecule.get_node("Label").text = "H" + G.indexs[2] + "O"
	
	add_child(molecule)

#############
#Удалить в-во
#############

func remove():
	for i in get_children():
		remove_child(i)
