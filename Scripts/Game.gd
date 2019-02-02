extends Node

# Scene to play when there's a winner
onready var gameWon = preload("res://Scenes/GameWon.tscn")
# Variable which describe what state is a winner state
onready var checker_win = {
	"row_one":[0,1,2],
	"row_two":[3,4,5],
	"row_three":[6,7,8],
	"col_one":[0,3,6],
	"col_two":[1,4,7],
	"col_three":[2,5,8],
	"dia_one":[0,4,8],
	"dia_two":[2,4,6]
}
# Store the state
var data_store = []
# Stores AI informations
var AI_store = {
	"---------":{
		0:1.0/9,
		1:1.0/9,
		2:1.0/9,
		3:1.0/9,
		4:1.0/9,
		5:1.0/9,
		6:1.0/9,
		7:1.0/9,
		8:1.0/9,
	}
}
# Store AI moves
var AI_moves = {}
var win = false

func get_main_node():
	var root = get_tree().get_root()
	return root.get_child(root.get_child_count() - 1)

func _ready():
	reset_data_store()
	load_AI()
	randomize()
	pass

func load_AI():
	var AI_save = File.new()
	AI_save.open("res://IA/ai.save", File.READ)
	AI_store = parse_json(AI_save.get_line())
	pass

func save_AI():
	var AI_save = File.new()
	AI_save.open("res://IA/ai.save", File.WRITE)
	AI_save.store_line(to_json(AI_store))
	AI_save.close()
	pass

func reset_data_store():
	data_store = []
	win = false
	for i in range(0,9):
		data_store.append("-")

func reset_AI():
	randomize()
	AI_moves = {}
	pass

func AI_learn(winner):
	var step
	# Si c'est l'IA qui a gagné, on va augmenter la proba des moves qu'elle a fait
	# Sinon, on baisse la proba des moves
	if (winner == "o"):
		step = 1.0/3
	else :
		step = -1.0/3
	
	# On modifie les probas des deux derniers moves, 
	# qui était ou prodigieux, ou tout moisis
	var hashCode = AI_moves.keys()
	AI_modify_proba(hashCode.pop_back(), step)
	AI_modify_proba(hashCode.pop_back(), step/3)
	
	# Si le jeu a duré longtemps (l'IA a fait plus de deux moves),
	# alors ses premiers moves n'étaient pas mals !
	if (hashCode.size() > 0):
		for h in hashCode:
			AI_modify_proba(h, abs(step)/3)
	pass

func AI_modify_proba(hashCode, step):
	# On met à jour les proba de l'état :
	var move = AI_moves[hashCode]
	var size = AI_store[hashCode].keys().size() - 1
	for i in AI_store[hashCode].keys():
		if (i != move):
			AI_store[hashCode][i] = max(0, AI_store[hashCode][i] - step/size)
		else :
			AI_store[hashCode][i] = min(1, AI_store[hashCode][i] + step)
	pass

func get_keys_for_value(value):
	var all_keys = checker_win.keys()
	var keys = []
	for i in range(0, all_keys.size()):
		var values = checker_win[String(all_keys[i])]
		for j in range(0, values.size()):
			if (values[j] == value):
				keys.append(String(all_keys[i]))
	return keys

func check_win(pos, letter):
	var tally = 0
	var key = []
	var keys_to_check = get_keys_for_value(pos)
	for i in range(0, keys_to_check.size()):
		key = keys_to_check[i]
		for j in range(0, checker_win[key].size()):
			if (data_store[checker_win[key][j]] == letter):
				tally += 1
		if (tally == 3):
			win = true
			break
		else:
			tally = 0
	if (win) :
		won_game(checker_win[key])

func won_game(win_key):
	var instance = gameWon.instance()
	var node = "POS" + String(win_key[1])
	instance.position = get_main_node().get_node("Grid/" + node).global_position
	var diff = win_key[2] - win_key[0]
	match diff :
		4:
			instance.rotation = deg2rad(-45)
		8:
			instance.rotation = deg2rad(45)
		6:
			instance.rotation = deg2rad(90)
	
	AI_learn(data_store[win_key[0]])
	get_main_node().add_child(instance)

func _process(delta):
	if (Input.is_key_pressed(KEY_ENTER)):
		get_tree().reload_current_scene()
		reset_data_store()
		reset_AI()
	if (Input.is_key_pressed(KEY_SPACE)):
		save_AI()

func play_AI():
	var hashCode = ""
	var proba = {}
	var keys_to_play = []
	
	# Compute pos where AI can play
	for j in range(0, 9):
		if (data_store[j] == "-"):
			keys_to_play.append(j)
	
	# Compute the hashCode of the state and get probabilities
	for i in range(0, 9):
		hashCode += data_store[i]
	
	# Take proba : if AI never reached this state, it adds it to the AI_store
	if (AI_store.has(hashCode)):
		proba = AI_store[hashCode]
	else:
		AI_store[hashCode] = get_new_AI_state(keys_to_play)
		proba = AI_store[hashCode]
	
	# Compute the move to do
	var a = randf()
	var sum = 0
	var move
	var n
	for j in range(0, proba.keys().size()):
		n = proba[proba.keys()[j]]
		sum += n
		if (a < sum):
			move = proba.keys()[j]
			break
	
	# Store the move and play it
	AI_moves[hashCode] = move
	var node = "POS" + String(move)
	get_main_node().get_node("Grid/" + node).play_o()
	pass

func get_new_AI_state(keys_to_play):
	var prob = 1.0/keys_to_play.size()
	var proba = {}
	for i in range(0, keys_to_play.size()):
		proba[keys_to_play[i]] = prob
	return proba

func print_proba():
	print("AI knowledge :")
	for i in AI_store.keys():
		print(i + " :" + String(AI_store[i]))
