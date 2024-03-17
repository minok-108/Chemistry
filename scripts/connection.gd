extends Node2D

func set_lines(ammount):
	match ammount:
		1:
			add_line(Vector2(0, 0))
		2:
			add_line(Vector2(0, -2))
			add_line(Vector2(0, 2))
		3:
			add_line(Vector2(0, -4))
			add_line(Vector2(0, 0))
			add_line(Vector2(0, 4))

func add_line(pos):
	var line = Line2D.new()
	
	line.add_point(Vector2(-16, 0))
	line.add_point(Vector2(16, 0))
	line.width = 2
	line.position = pos
	
	add_child(line)
