extends Area2D

onready var x = preload("res://Sprites/Cross.png")
onready var o = preload("res://Sprites/Circle.png")

var selected = false
export var pos = -1

func _ready():
	$Mouse_over.hide()

func _on_POS_mouse_entered():
	if (!selected and !Game.win):
		$Mouse_over.show()

func _on_POS_mouse_exited():
	$Mouse_over.hide()

func play_x():
	if (!selected and !Game.win and Game.data_store[pos] == "-"):
		$x_o.set_texture(x)
		Game.data_store[pos] = "x"
		Game.check_win(pos, "x")
		if Game.data_store.has("-"):
			Game.play_AI()

func play_o():
	if (!selected and !Game.win):
		$x_o.set_texture(o)
		Game.data_store[pos] = "o"
		Game.check_win(pos, "o")

func _on_POS_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton):
		if (event.button_index == BUTTON_LEFT):
			play_x()
			$Mouse_over.hide()
			selected = true
	pass # replace with function body
