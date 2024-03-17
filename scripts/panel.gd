extends Control

var showing = true

func _on_button_pressed():
	showing = !showing
	if showing == true:
		$Animation.play("view")
	else:
		$Animation.play("hide")
