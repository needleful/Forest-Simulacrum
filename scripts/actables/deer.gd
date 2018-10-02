extends Spatial

onready var G = get_node("/root/global")
onready var b:Talkable = $body

var required_items = {'Flower':4}
var optional_items = {'Flower':4, 'Chamomile':1}

var house_phase=1

var house_requirements = [
	{"Tree_Small":5},
	{"Tree_Large":8},
	{"Tree_Master":1}
]

func _ready():
	b.anim_player = $AnimationPlayer
	$AnimationPlayer.get_animation("Idle").loop = true
	$AnimationPlayer.play("Idle")
	$AnimationPlayer.animation_set_next("Sneeze", "Idle")
	
	b.connect("enter", self, "on_enter")
	b.connect("exit", self,  "on_exit")
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
		if G.has_item("wrath"):
			b.dialog_entry = "Doom"
		elif b.met(house_requirements[house_phase-1]):
			b.dialog_entry = "House_%d_Build" % house_phase
		elif G.has_item("saw"):
			if b.talked:
				b.dialog_entry = "House_%d_Questions" % house_phase
			else:
				b.dialog_entry = "House_%d_Harvest" % house_phase
func on_exit():
	if G.phase == G.HOUSE and b.dialog_entry == "House_%d_Build" % house_phase:
		house_phase += 1
		b.talked = false

func on_phase_change(old_phase, new_phase):
	b.talked = false
	match new_phase:
		G.HOUSE:
			b.talked = false
			b.dialog_source = $dlg_phase_2.source_path
			if G.has_item("forbidden_knowledge"):
				b.dialog_entry = "TeaTime-Portrait"
			elif G.has_item("tea"):
				b.dialog_entry = "TeaTime"
			else:
				b.dialog_entry = "Home"
		_:
			print_debug("Invalid phase transition: %s to %s",
				[str(old_phase), str(new_phase)])