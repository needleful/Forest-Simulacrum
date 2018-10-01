extends Spatial

onready var G = get_node("/root/global")
onready var b:Talkable = $body

var required_items = {'Flower':4}
var optional_items = {'Flower':4, 'Chamomile':1}

func _ready():
	b.anim_player = $AnimationPlayer
	$AnimationPlayer.get_animation("Idle").loop = true
	$AnimationPlayer.play("Idle")
	$AnimationPlayer.animation_set_next("Sneeze", "Idle")
	
	b.connect("enter", self, "on_enter")
	G.connect("phase_change", self, "on_phase_change")


func on_enter():
	if G.phase == G.FLOWERS:
		if b.met(optional_items):
			b.dialog_entry = "Optional"
		elif b.met(required_items):
			b.dialog_entry = "RequirementsMet"
		elif b.talked:
			b.dialog_entry = "Questions"
	elif G.phase == G.HOUSE:
		if b.talked && G.has_item("saw"):
			pass

func on_phase_change(old_phase, new_phase):
	$body.talked = false
	match new_phase:
		G.HOUSE:
			b.dialog_source = $dlg_phase_2.source_path
			if G.has_item("forbidden_knowledge"):
				b.dialog_entry = "TeaTime-Portrait"
			elif G.has_item("tea"):
				b.dialog_entry = "TeaTime"
			else:
				b.dialog_entry = "Home"
			required_items = {}
			optional_items = {}
		_:
			print_debug("Invalid phase transition: %s to %s",
				[str(old_phase), str(new_phase)])