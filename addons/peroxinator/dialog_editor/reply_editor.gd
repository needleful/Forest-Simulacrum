extends HBoxContainer

signal reply_deleted(reply)
var reply

onready var t:OptionButton = $type
var circle = load("res://addons/peroxinator/dialog_editor/icons/replies/Circle.svg")
var spade = load("res://addons/peroxinator/dialog_editor/icons/replies/Spade.svg")
var club = load("res://addons/peroxinator/dialog_editor/icons/replies/Club.svg")
var heart = load("res://addons/peroxinator/dialog_editor/icons/replies/Heart.svg")
var diamond = load("res://addons/peroxinator/dialog_editor/icons/replies/Diamond.svg")

func _ready():
	t.add_icon_item(circle,"",0)
	t.add_icon_item(spade,"",1)
	t.add_icon_item(club,"",2)
	t.add_icon_item(heart,"",3)
	t.add_icon_item(diamond,"",4)
	t.connect("item_selected", self, "change_type")
	$text.connect("text_changed", self, "set_text")

func bind_reply(reply):
	self.reply = reply
	$text.text = reply.text
	set_type(reply.type)

func change_type(val:int):
	var type
	match(val):
		0:
			type = "Circle"
		1:
			type = "Spade"
		2:
			type = "Club"
		3:
			type = "Heart"
		4:
			type = "Diamond"
	reply.type = type

func set_type(val):
	var type
	match(val):
		"Circle":
			type=0
		"Spade":
			type=1
		"Club":
			type=2
		"Heart":
			type=3
		"Diamond":
			type=4
	t.select(type)

func set_text():
	reply.text = $text.text

func delete_reply():
	if reply != null:
		emit_signal("reply_deleted", reply)
	queue_free()

