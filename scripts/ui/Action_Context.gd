extends Control

var enabled = true
var has_selected = false
var selected
var player

var talk_icon : Texture = load("res://assets/icons/talk.svg")
var grab_icon : Texture = load("res://assets/icons/grab.svg")
var view_icon : Texture = load("res://assets/icons/view.svg")
var saw_icon : Texture = load("res://assets/icons/saw.svg")

func _ready():
	hide()
	
func bind_player(p):
	player = p
	
func select(object):
	if !object.active:
		return
	if object.action_type == "talk":
		$TextureRect.texture = talk_icon
	elif object.action_type == "take":
		$TextureRect.texture = grab_icon
	elif object.action_type == "view":
		$TextureRect.texture = view_icon
	elif object.action_type == "saw":
		$TextureRect.texture = saw_icon
	selected = object
	has_selected = true
	show()
	
func deselect():
	has_selected = false
	hide()
	
func act():
	hide()
	enabled = false
	has_selected = false
	selected.connect("exit", self, "act_exit", [], CONNECT_ONESHOT)
	player.can_move = false
	selected.act()

func act_exit():
	player.can_move = true
	enabled = true