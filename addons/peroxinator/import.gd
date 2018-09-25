tool
extends EditorImportPlugin

const DialogTree = preload("res://addons/peroxinator/dialog_tree.gd")

func get_importer_name():
	return "peroxinator.dlg"

func get_visible_name():
	return "Peroxinator Dialog Editor"

func get_recognized_extensions():
	return ["json", "dlg"]

func get_save_extension():
	return "prx"

func get_resource_type():
	return "Resource"

func get_preset_count():
	return 1

func get_preset_name(i):
	return "Default"

func get_import_options(i):
	return [{"name": "my_option", "default_value": false}]

func import(src, dst, opts, r_platform_variants, r_gen_files):
	var dlg = DialogTree.new(src)
	if dlg == null:
		return ERR_INVALID_DATA
		
	var save = dst + "." + get_save_extension()
	var err = ResourceSaver.save(save, dlg)
	if err != OK:
		return err
	return OK