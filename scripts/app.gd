extends Control

@onready var b_type_substance_1 = $"../Top/Panel/ButtonTypeSubstance1"
@onready var b_type_substance_2 = $"../Top/Panel/ButtonTypeSubstance2"

@onready var b_length_substance_1 = $"../Top/Panel/ButtonTypeSubstance1/ButtonLength"
@onready var b_double_place_substance_1 = $"../Top/Panel/ButtonTypeSubstance1/ButtonDoublePlace"

@onready var sub_1 = $Substance1
@onready var sub_2 = $Substance2

#######
#Кнопки
#######

func _on_button_type_substance_1_item_selected(index):
	sub_1.sub.type = G.types_substance_1[index]
	
	b_length_substance_1.visible = false
	b_double_place_substance_1.visible = false
	
	b_length_substance_1.set_item_disabled(1, false)
	b_length_substance_1.set_item_disabled(2, false)
	
	match sub_1.sub.type:
		"Alkane":
			b_length_substance_1.visible = true
		"Alkene", "Alkyne":
			if sub_1.sub.length == 1:
				sub_1.sub.length = 2
				b_length_substance_1.selected = 2
			
			b_length_substance_1.visible = true
			b_double_place_substance_1.visible = true
			
			b_length_substance_1.set_item_disabled(1, true)
		"Cycloalkane":
			b_length_substance_1.visible = true
			
			b_length_substance_1.set_item_disabled(1, true)
			b_length_substance_1.set_item_disabled(2, true)
		"Benzene":
			sub_1.sub.length = 6
			b_length_substance_1.selected = 6
	
	update_button_double_place()
	substance_1(true)

func _on_button_length_item_selected(index):
	sub_1.sub.length = index
	
	update_button_double_place()
	substance_1(true)

func _on_button_double_place_item_selected(index):
	sub_1.sub.double_place = index
	
	substance_1(true)

func _on_button_type_substance_2_item_selected(index):
	sub_2.type = G.types_substance_2[index]
	
	substance_2()


func _on_button_show_question_toggled(toggled_on):
	sub_1.sub.with_question = toggled_on
	substance_1(false)


func update_button_double_place():
	if sub_1.sub.length == 0:
		sub_1.sub.double_place = 0
	elif sub_1.sub.double_place >= sub_1.sub.length:
		sub_1.sub.double_place = sub_1.sub.length - 1
	
	b_double_place_substance_1.selected = sub_1.sub.double_place
	
	for i in range(1, 10):
		if i < sub_1.sub.length:
			b_double_place_substance_1.set_item_disabled(i, false)
		else:
			b_double_place_substance_1.set_item_disabled(i, true)

#
#
#

func update_radius_angles_heights():
	var a = PI / sub_1.sub.length
	
	sub_1.sub.r = 40 / (2 * sin (PI / (sub_1.sub.length * 2))) #радиус 2*length-угольника
	sub_1.sub.r2 = 40 / (2 * sin(a)) #радиус length-угольника
	sub_1.sub.angle = a + 2 * asin((sub_1.sub.r2 * sin(a / 2)) / 40.0) #угл между радикалами
	sub_1.sub.h = sub_1.sub.r * cos(a) #высота к стороне многоугольника из центра
	sub_1.sub.h2 = 80 * sin((PI - sub_1.sub.angle) / 2) #высота из вершины цикла к прямой между радикалами

func substance_1(new):
	sub_1.remove()
	
	if new == true:
		if sub_1.sub.type == "Alcohol" or sub_1.sub.type == "Ketone" or sub_1.sub.type == "Aldehyde":
			sub_1.sub.type = "Alkane"
	
	if (sub_1.sub.type == "Alkane" or sub_1.sub.type == "Alcohol" or sub_1.sub.type == "Ketone"\
		or sub_1.sub.type == "Aldehyde") and sub_1.sub.length != 0:
			b_type_substance_2.visible = true
			sub_1.set_substance(new)
			update_position()
	
	elif (sub_1.sub.type == "Alkene" or sub_1.sub.type == "Alkyne") and \
		sub_1.sub.length != 0 and sub_1.sub.double_place != 0:
			b_type_substance_2.visible = true
			sub_1.set_substance(new)
			update_position()
	
	elif sub_1.sub.type == "Cycloalkane" and \
		sub_1.sub.length != 0:
			update_radius_angles_heights()
			
			b_type_substance_2.visible = true
			sub_1.set_substance(new)
			update_position()
	
	elif sub_1.sub.type == "Benzene":
		update_radius_angles_heights()
		
		b_type_substance_2.visible = true
		sub_1.set_substance(new)
		update_position()
	
	else:
		remove_substance_2()
	
	if G.substance_2_exists == true:
		answer()

func remove_substance_2():
	G.substance_2_exists = false
	sub_2.type = "None"
	
	$Plus.visible = false
	$Equal.visible = false
	
	b_type_substance_2.selected = 0
	b_type_substance_2.visible = false
	sub_2.remove()
	$Answer.remove()

func substance_2():
	sub_2.remove()
	
	if sub_2.type != "None":
		G.substance_2_exists = true
		sub_2.set_substance()
		
		answer()
	else:
		G.substance_2_exists = false
		update_position()
		
		remove_answer()

func remove_answer():
	$Answer.remove()

func answer():
	$Answer.remove()
	
	$Answer.reaction()
	update_position()

########
#Позиция
########



func update_position():
	var size_sub_1 = sub_1.get_size()
	var size_sub_2 = sub_2.get_size()
	var size_answer = $Answer.get_size()
	
	var f = 1 #scale factor (сократил до f т. к. слишком часто используется)
	
	if G.substance_2_exists == true:
		var start_pos = (880 - size_sub_1.x - size_sub_2.x - size_answer.x) / 2
	
		if start_pos < 0:
			f = 960 / (960 + 80 + 2 * abs(start_pos))
		
		start_pos = (960 - size_sub_1.x * f - size_sub_2.x * f - size_answer.x * f - 80 * f) / 2
		
		$Plus.visible = true
		$Equal.visible = true
		
		sub_1.scale = Vector2(f, f)
		$Plus.scale = Vector2(f, f)
		sub_2.scale = Vector2(f, f)
		$Equal.scale = Vector2(f, f)
		$Answer.scale = Vector2(f, f)
		
		sub_1.position = Vector2(start_pos, 270)
		$Plus.position = Vector2(start_pos + size_sub_1.x * f, 270 - 20 * f)
		sub_2.position = Vector2(start_pos + size_sub_1.x * f + 40 * f, 270)
		$Equal.position = Vector2(start_pos + size_sub_1.x * f + size_sub_2.x * f + 40 * f, 270 - 20 * f)
		$Answer.position = Vector2(start_pos + size_sub_1.x * f + size_sub_2.x * f + 80 * f, 270)
	
	elif G.substance_2_exists == false:
		var start_pos = (960 - size_sub_1.x - 80) / 2
		
		if start_pos < 0:
			f = 960 / (960 + 80 + 2 * abs(start_pos))
		
		start_pos = (960 - size_sub_1.x * f) / 2
		
		sub_1.scale = Vector2(f, f)
		
		$Plus.visible = false
		$Equal.visible = false
		
		sub_1.position = Vector2(start_pos, 270)


func _on_button_language_item_selected(index):
	TranslationServer.set_locale($"../Top/Panel/ButtonLanguage".get_item_text(index))
	Name.update_name()

