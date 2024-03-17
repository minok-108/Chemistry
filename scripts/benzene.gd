extends Node


func set_molecules(host, sub):
	for i in range(sub.length):
		var hydrogen = G.count_hydrogen(sub, i)
		
		host.set_molecule(
			G.set_molecule_text(hydrogen),
			Vector2(
				cos(2 * PI / sub.length * i) * sub.r + sub.r + sub.add_distance_l + 20,
				sin(2 * PI / sub.length * i) * sub.r
			)
		)


func set_connections(host, sub):
	var add_h = 0 #т. к. 3 4 слишком маленькие циклы
	if sub.length == 3 or sub.length == 4:
		add_h = 10
	
	for i in range(sub.length):
		var number_of_connections = 1
		if i % 2 == 1:
			number_of_connections = 2
		
		host.set_connection(
			Vector2(
				cos(2 * PI / (2 * sub.length) * (2 * i + 1)) * (sub.h + add_h) + sub.r + sub.add_distance_l + 20,
				sin(2 * PI / (2 * sub.length) * (2 * i + 1)) * (sub.h + add_h)
				),
			PI - (PI * (sub.length - 2)) / sub.length * i - ((PI * (sub.length - 2)) / sub.length) * 0.5,
			number_of_connections
		)


func set_radicals(host, sub):
	for i in range(len(sub.radicals)):
		for j in range(len(sub.radicals[i])):
			var radical = sub.radicals[i][j]
			if radical != null:
				host.set_molecule(
					radical.value,
					Vector2(
						cos(2 * PI / sub.length * i) * (sub.r + 80) + sub.r + sub.add_distance_l + 20,
						sin(2 * PI / sub.length * i) * (sub.r + 80)
					)
				)
				
				host.set_connection(
					Vector2(
						cos(2 * PI / sub.length * i) * (sub.r + 40) + sub.r + sub.add_distance_l + 20,
						sin(2 * PI / sub.length * i) * (sub.r + 40)
					),
					2 * PI / sub.length * i,
					1
				)


func set_questions(host, sub):
	for i in range(len(sub.radicals)):
		for j in range(len(sub.radicals[i])):
			var radical = sub.radicals[i][j]
			if radical == null:
				if G.count_hydrogen(sub, i) != 0:
					var question = G.s_question.instantiate()
					
					question.position.x = cos(2 * PI / sub.length * i) * (sub.r + 80) + sub.r + 100
					question.position.y = sin(2 * PI / sub.length * i) * (sub.r + 80)
					
					question.pos = i
					question.side = j
					host.add_child(question)
