class_name MainMenu extends MenuButton

signal project_changed(project:BaseItem)
signal recent_project_pressed(index:int)

enum Menu {
	NEW_PROJECT,
	SAVE_PROJECT,
	SAVE_PROJECT_AS,
	OPEN_PROJECT,
	OPEN_RECENT,
	SETTING,
	QUTI
}

var project_ctr:ProjectContoller

var popup:PopupMenu:
	get: return get_popup()

#--------------------------------------------------------------------------------------------------
func _ready():
	about_to_popup.connect(init_menubutton)
	init_menubutton()
	popup.id_pressed.connect(menubutton_call)
	
#--------------------------------------------------------------------------------------------------
func init_menubutton():
	popup.clear(true)
	popup.add_item("New Project", Menu.NEW_PROJECT)
	popup.add_item("Save Project", Menu.SAVE_PROJECT)
	popup.add_item("Save Project As...", Menu.SAVE_PROJECT_AS)
	popup.add_item("Open Project", Menu.OPEN_PROJECT)
	
	var recents = FileManager.get_recent_list()
	if recents:
		var submenu := PopupMenu.new()
		for i in recents:
			submenu.add_item(i)
		submenu.index_pressed.connect(open_recent)
		popup.add_submenu_node_item("Open Recent", submenu, Menu.OPEN_RECENT)
		
	popup.add_separator()
	popup.add_item("Setting", Menu.SETTING)
	popup.add_separator()
	popup.add_item("Quit", Menu.QUTI)


#--------------------------------------------------------------------------------------------------
func menubutton_call(id:int):
	var current_project = project_ctr.get_project()
	match id:
		Menu.NEW_PROJECT: 
			new_project() 
			
		Menu.OPEN_PROJECT: 
			open_project()
			
		Menu.SAVE_PROJECT: 
			if save_project(current_project) != OK:
				save_project_as(current_project)
				
		Menu.SAVE_PROJECT_AS:
			save_project_as(current_project)
			project_changed.emit(current_project)

#--------------------------------------------------------------------------------------------------
func gdc_file_dialog(title:String, mode:DisplayServer.FileDialogMode) -> Array:
	var gdc_filter = "*.%s"%FileManager.GDC_EXTENSION
	return Utils.file_dialog(title, [gdc_filter], mode)


#---------------------------------------------------------------------------------------------------
func quick_open():
	for file in FileManager.get_recent_list():
		if not FileAccess.file_exists(file):
			continue
		if file.get_extension() != FileManager.GDC_EXTENSION:
			continue
		project_changed.emit(FileManager.open_project(file))
		break

#---------------------------------------------------------------------------------------------------
func save_current() -> bool:
	# 如果想继续后续的操作返回 true 否则返回 false
	var current_project = project_ctr.get_project()
	var file_path = current_project.get_title()
	var RC := CustomConfirmationDialog.ResultCode
	if save_project(current_project) != OK:
		match await confirm_save_project():
			RC.OK:
				if save_project_as(current_project) != OK:
					return false
			RC.CANCEL:
				return false
			RC.DISCARD:
				pass
	return true
	
#--------------------------------------------------------------------------------------------------
func new_project():
	if not await save_current():
		return 
	var files = gdc_file_dialog("New Project", DisplayServer.FILE_DIALOG_MODE_SAVE_FILE)
	if not files:
		return 
	var file_path = files[0]
	if file_path.get_extension() != FileManager.GDC_EXTENSION:
		file_path += ".%s"%FileManager.GDC_EXTENSION
	var project = FileManager.new_project(file_path)
	if project:
		project_changed.emit(project)

#--------------------------------------------------------------------------------------------------
func open_project():
	if not await save_current():
		return 
	var files = gdc_file_dialog("Open Project", DisplayServer.FILE_DIALOG_MODE_OPEN_FILE)
	if not files:
		return 
	var file_path = files[0]
	if file_path.get_extension() != FileManager.GDC_EXTENSION:
		return 
	var project = FileManager.open_project(file_path)
	if project:
		project_changed.emit(project)

#---------------------------------------------------------------------------------------------------
func open_recent(index:int):
	if not await save_current():
		return 
	var files = FileManager.get_recent_list()
	if files.size() <= index:
		return 
	var file_path = files[index]
	if not FileAccess.file_exists(file_path):
		return 
	if file_path.get_extension() != FileManager.GDC_EXTENSION:
		return 
	var project = FileManager.open_project(file_path)
	if project:
		project_changed.emit(project)

#--------------------------------------------------------------------------------------------------
func save_project(project:BaseItem) -> Error:
	# 如果默认保存路径存在就返回 OK 
	var file_path = project.get_title()
	if FileAccess.file_exists(file_path):
		FileManager.save_project(project)
		add_to_recent(file_path)
		return OK
	return FAILED
	
#--------------------------------------------------------------------------------------------------
func save_project_as(project:BaseItem) -> Error:
	var files = gdc_file_dialog("Save Project as", DisplayServer.FILE_DIALOG_MODE_SAVE_FILE)
	if not files:
		return FAILED
	var file_path = files[0]
	if file_path.get_extension() != FileManager.GDC_EXTENSION:
		file_path += ".%s"%FileManager.GDC_EXTENSION
	project.set_title(file_path)
	FileManager.save_project(project)
	add_to_recent(file_path)
	return OK
	
#--------------------------------------------------------------------------------------------------
func confirm_save_project() -> CustomConfirmationDialog.ResultCode:
	var confirm := CustomConfirmationDialog.new()
	add_child(confirm)
	var result_helper := confirm.init_with_discard("Save Project as", 
										"Do you want to save current project?",
										)
	confirm.show()
	await result_helper.successed
	return confirm.result

#--------------------------------------------------------------------------------------------------
func add_to_recent(file_path:String):
	FileManager.add_to_recent_list(file_path)
	AssetUtils.save_configs(AssetUtils.S_SETTINGS, AssetUtils.K_RECENT_PROJECTS, FileManager.get_recent_list())
	

		
