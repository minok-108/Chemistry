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
		host.set_connection(
			Vector2(
				cos(2 * PI / (2 * sub.length) * (2 * i + 1)) * (sub.h + add_h) + sub.r + sub.add_distance_l + 20,
				sin(2 * PI / (2 * sub.length) * (2 * i + 1)) * (sub.h + add_h)
				),
			PI - (PI * (sub.length - 2)) / sub.length * i - ((PI * (sub.length - 2)) / sub.length) * 0.5,
			1
		)


func set_radicals(host, sub):
	for i in range(len(sub.radicals)):
		for j in range(len(sub.radicals[i])):
			var radical = sub.radicals[i][j]
			if radical != null:
				var side = 1
				if j == 1: side = -1
				if (sub.radicals[i][0] == null or sub.radicals[i][1] == null) and sub.with_question == false:
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
				
				else:
					host.set_molecule(
						radical.value,
						Vector2(
							cos(2 * PI / sub.length * i) * sub.r + sub.r + sub.add_distance_l + 20 \
								+ cos(2 * PI / sub.length * i + sub.angle / 2 * side) * 80,
							sin(2 * PI / sub.length * i) * sub.r \
								+ sin(2 * PI / sub.length * i + sub.angle / 2 * side) * 80
						)
					)
					
					host.set_connection(
						Vector2(
							cos(2 * PI / sub.length * i) * sub.r + sub.r + sub.add_distance_l + 20 \
								+ cos(2 * PI / sub.length * i + sub.angle / 2 * side) * 40,
							sin(2 * PI / sub.length * i) * sub.r \
								+ sin(2 * PI / sub.length * i + sub.angle / 2 * side) * 40
						),
						2 * PI / sub.length * i + sub.angle / 2 * side,
						1
					)


func set_questions(host, sub):
	for i in range(len(sub.radicals)):
		for j in range(len(sub.radicals[i])):
			var radical = sub.radicals[i][j]
			if radical == null:
				if G.count_hydrogen(sub, i) != 0:
					var question = G.s_question.instantiate()
					var pos_molecule = Vector2()
					var side = 1
					if j == 1: side = -1
					
					pos_molecule.x = cos(2 * PI / sub.length * i) * sub.r + sub.r + sub.h2 + 20
					pos_molecule.y = sin(2 * PI / sub.length * i) * sub.r
					
					pos_molecule.x += cos(2 * PI / sub.length * i + sub.angle / 2 * side) * 80
					pos_molecule.y += sin(2 * PI / sub.length * i + sub.angle / 2 * side) * 80
					
					question.position = pos_molecule
					question.pos = i
					question.side = j
					host.add_child(question)
