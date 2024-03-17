extends Node

var s_molecule = load("res://nodes/Molecule.tscn")
var s_symbol = load("res://nodes/Symbol.tscn")
var s_connection = load("res://nodes/Connection.tscn")
var s_question = load("res://nodes/Question.tscn")

var substance_2_exists = false

var types_substance_1 = ["None", "Alkane", "Alkene", "Alkyne", "Cycloalkane", "Benzene"]
var types_substance_2 = ["None", "H2", "O2", "Cl2", "Na", "HCl", "H2O"]

var indexs = ["₀", "", "₂", "₃", "₄"]

#
#
#

func count_radicals(sub, number): #для циклов
	var ammount_of_radicals = 0
	for i in range(len(sub.radicals[number])):
		if sub.radicals[number][i] != null:
			ammount_of_radicals += 1
	
	return ammount_of_radicals


func update_size(sub):
	var size = Vector2()
	sub.add_distance_r = 0
	sub.add_distance_l = 0
	
	match sub.type:
		"Alkane", "Alkene", "Alkyne", "Alcohol", "Ketone":
			if sub.with_question == true:
				sub.add_distance_r = 80
				sub.add_distance_l = 80
			else:
				if sub.length != 1:
					if sub.radicals[0][2] != null: sub.add_distance_l = 80
					if sub.radicals[sub.length - 1][2] != null: sub.add_distance_r = 80
				else:
					if sub.radicals[0][2] != null: sub.add_distance_l = 80
					if sub.radicals[sub.length - 1][3] != null: sub.add_distance_r = 80
			
			size = Vector2(40 * (2 * sub.length - 1) + sub.add_distance_r + sub.add_distance_l, 0)
		
		"Aldehyde":
			if sub.radicals[sub.length - 1][2] != null and sub.radicals[sub.length - 1][2].value == "O":
				sub.add_distance_r = pow(3200, 0.5)
				
				if sub.with_question == true: sub.add_distance_l = 80
				else: if sub.radicals[0][2] != null: sub.add_distance_l = 80
			
			elif sub.radicals[0][2] != null and sub.radicals[0][2].value == "O":
				sub.add_distance_l = pow(3200, 0.5)
				
				if sub.with_question == true: sub.add_distance_r = 80
				else: if sub.radicals[sub.length - 1][2] != null: sub.add_distance_r = 80
			
			if sub.length == 1 and sub.radicals[0][3] != null and sub.radicals[0][3].value == "O":
				sub.add_distance_r = pow(3200, 0.5)
				
				if sub.with_question == true: sub.add_distance_l = 80
				else: if sub.radicals[0][2] != null: sub.add_distance_l = 80
			
			size = Vector2(40 * (2 * sub.length - 1) + sub.add_distance_r + sub.add_distance_l, 0)
		
		"Cycloalkane":
			if sub.with_question == true:
				sub.add_distance_r = sub.h2
				sub.add_distance_l = sub.h2
			else:
				match count_radicals(sub, 0):
					0: sub.add_distance_r = 0
					1: sub.add_distance_r = 80
					2: sub.add_distance_r = sub.h2
				
				if sub.length % 2 == 0:
					match count_radicals(sub, sub.length / 2):
						0: sub.add_distance_l = 0
						1: sub.add_distance_l = 80
						2: sub.add_distance_l = sub.h2
				
				elif sub.length % 2 == 1:
					var a1 = ((PI / 2) * (sub.length - 2)) / sub.length
					var a2 = PI - 0.5 * sub.angle - (0.5 * PI * (sub.length - 2) / sub.length)
					
					var add_h1 = 0
					var add_h2 = 0
					
					match count_radicals(sub, sub.length / 2):
						1: add_h1 = 80 * sin(a1)
						2: add_h1 = 80 * sin(a2)
					
					match count_radicals(sub, sub.length / 2 + 1):
						1: add_h2 = 80 * sin(a1)
						2: add_h2 = 80 * sin(a2)
					
					sub.add_distance_l = max(add_h1, add_h2)
			
			size = Vector2(2 * sub.r + sub.add_distance_r + sub.add_distance_l + 40, 0)
			
		"Benzene":
			if sub.with_question == true:
				sub.add_distance_r = 80
				sub.add_distance_l = 80
			else:
				match count_radicals(sub, 0):
					0: sub.add_distance_r = 0
					1: sub.add_distance_r = 80
				
				if sub.length % 2 == 0:
					match count_radicals(sub, sub.length / 2):
						0: sub.add_distance_l = 0
						1: sub.add_distance_l = 80
			
			size = Vector2(2 * sub.r + sub.add_distance_r + sub.add_distance_l + 40, 0)
	
	return size

#
#
#

func set_molecule_text(hydrogen):
	var molecule_text = ""
	
	if hydrogen != 0:
		molecule_text = "CH" + indexs[hydrogen]
	else:
		molecule_text = "C"
	
	return molecule_text

func count_hydrogen(sub, number):
	var hydrogen = 0
	match sub.type:
		"Alkane", "Alkene", "Alkyne", "Alcohol", "Ketone", "Aldehyde":
			hydrogen = 4
			
			if sub.length - 1 == 0:
				pass
			elif number == 0 or number == sub.length - 1:
				hydrogen -= 1
			else:
				hydrogen -= 2
			
			if sub.double_place != 0:
				if number == sub.double_place - 1 or number == sub.double_place:
					if sub.type == "Alkene":
						hydrogen -= 1
					elif sub.type == "Alkyne":
						hydrogen -= 2
			
			if sub.type == "Aldehyde":
				if number == 0 or number == sub.length - 1:
					hydrogen -= 1
					
		
		"Cycloalkane":
			hydrogen = 2
		
		"Benzene":
			hydrogen = 1
	
	for radical in sub.radicals[number]:
		if radical != null:
			hydrogen -= radical.number_of_connections
	
	return hydrogen

#####################
#Alkane alkene alkyne
#####################

func create_substance(host, sub):
	match sub.type:
		"Alkane", "Alkene", "Alkyne", "Ketone", "Alcohol", "Aldehyde":
			$AlkaneAlkeneAlkyne.set_molecules(host, sub)
			$AlkaneAlkeneAlkyne.set_connections(host, sub)
			$AlkaneAlkeneAlkyne.set_radicals(host, sub)
		"Cycloalkane":
			$Cycloalkane.set_molecules(host, sub)
			$Cycloalkane.set_connections(host, sub)
			$Cycloalkane.set_radicals(host, sub)
		"Benzene":
			$Benzene.set_molecules(host, sub)
			$Benzene.set_connections(host, sub)
			$Benzene.set_radicals(host, sub)

func set_questions(host, sub):
	match sub.type:
		"Alkane", "Alkene", "Alkyne", "Ketone", "Alcohol", "Aldehyde":
			$AlkaneAlkeneAlkyne.set_questions(host, sub)
		"Cycloalkane":
			$Cycloalkane.set_questions(host, sub)
		"Benzene":
			$Benzene.set_questions(host, sub)
