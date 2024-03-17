extends Node


func set_molecules(host, sub):
	for i in range(sub.length):
		host.set_molecule(
			G.set_molecule_text(G.count_hydrogen(sub, i)),
			Vector2(20 + 40 * 2 * i + sub.add_distance_l, 0)
		)


func set_connections(host, sub):
	for i in range(sub.length - 1):
		var number_of_connections = 1
		if i == sub.double_place - 1:
			if sub.type == "Alkene": number_of_connections = 2
			elif sub.type == "Alkyne": number_of_connections = 3
		
		host.set_connection(Vector2(60 + 80 * i + sub.add_distance_l, 0), 0, number_of_connections)


func set_radicals(host, sub):
	for i in range(len(sub.radicals)):
		for j in range(len(sub.radicals[i])):
			var radical = sub.radicals[i][j]
			if radical != null:
				var pos_x = 20 + 80 * i + sub.add_distance_l
				if sub.type == "Aldehyde" and radical.value == "O":
					var dist = pow(3200, 0.5)
					var factor = 1
					
					if i == sub.length - 1 and (sub.length - 1 != 0 or j != 2): factor = -1
					
					host.set_molecule("O",Vector2(pos_x - dist * factor, -dist))
					host.set_molecule("H", Vector2(pos_x - dist * factor, dist))
					
					host.set_connection(
						Vector2(pos_x - dist / 2 * factor, -dist / 2), PI / 4 * factor, 2)
					host.set_connection(
						Vector2(pos_x - dist / 2 * factor, dist / 2 ), -PI / 4 * factor, 1)
					
					continue
				
				var r_add_pos = 0 #для крайних радикалов
				var c_angle = PI / 2
				var factor_side = 1
				
				if j == 1:
					factor_side = -1
				
				elif j == 2:
					factor_side = 0
					if i == 0:
						r_add_pos = -80
						c_angle = 0
					elif i == sub.length - 1:
						r_add_pos = 80
						c_angle = 0
				elif j == 3: #только для метана
					factor_side = 0
					r_add_pos = 80
					c_angle = 0
				
				host.set_molecule(
					radical.value,
					Vector2(pos_x + r_add_pos, -80 * factor_side)
				)
				
				host.set_connection(
					Vector2(pos_x + int(r_add_pos / 2.0), -40 * factor_side),
					c_angle,
					radical.number_of_connections
				)


func set_questions(host, sub):
	for i in range(len(sub.radicals)):
		for j in range(len(sub.radicals[i])):
			var radical = sub.radicals[i][j]
			if radical == null:
				if G.count_hydrogen(sub, i) != 0:
					var side = 1
					var r_add_pos = 0 #для крайних радикалов
					
					if j == 1:
						side = -1
					elif j == 2:
						side = 0
						if i == 0: r_add_pos = - 80
						elif i == sub.length - 1: r_add_pos = 80
					elif j == 3: #только для метана
						side = 0
						r_add_pos = 80
					
					var question = G.s_question.instantiate()
					question.position = Vector2(20 + 80 * i + sub.add_distance_l + r_add_pos, -80 * side)
					question.pos = i
					question.side = j
					host.add_child(question)
