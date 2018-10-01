extends Control

func _input(event):
	if event.is_action_pressed("gm_pause"):
		get_tree().quit()

func _ready():
	set_process_input(true)
	$AnimationPlayer.queue("EndTimes")

func _on_Music_finished():
	get_tree().quit()
