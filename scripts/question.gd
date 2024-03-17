extends Node2D

@onready var sub_1 = get_parent().sub

var pos = 0
var side = 0

func _on_button_value_pressed():
	$ButtonValue.visible = true
	$ButtonValue.show_popup()
	
	if (sub_1.type == "Alkane" or sub_1.type == "Alkene" or sub_1.type == "Alkyne" or sub_1.type == "Alcohol" or sub_1.type == "Ketone" or sub_1.type == "Aldehyde") \
		and (pos == 0 or pos == sub_1.length - 1):
			$ButtonValue.set_item_disabled(0, true)
	
	if sub_1.type != "Alkane":
		$ButtonValue.set_item_disabled(2, true)
		$ButtonValue.set_item_disabled(3, true)


func close_list():
	$ButtonValue.visible = false


func _on_button_value_item_selected(index):
	var value = $ButtonValue.get_item_text(index)
	
	if value == "OH":
		sub_1.type = "Alcohol"
	
	if value == "O":
		if pos == 0 or pos == sub_1.length - 1:
			sub_1.type = "Aldehyde"
			if side != 3:
				side = 2
		else:
			sub_1.type = "Ketone"
	
	var number_of_connections = 1
	if value == "O":
		number_of_connections = 2
	
	get_parent().add_radical(pos, value, side, number_of_connections)
	queue_free()
