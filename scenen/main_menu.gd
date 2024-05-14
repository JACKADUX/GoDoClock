class_name MainMenu extends MenuButton

signal project_changed(project:BaseItem)
signal quit_request

enum Menu {
	NEW_PROJECT,
	SAVE_PROJECT,
	SAVE_PROJECT_AS,
	OPEN_PROJECT,
	OPEN_RECENT,
	PROJECT_FOLDER,
	SETTING,
	QUTI
}

var project_ctr:ProjectContoller

var popup:PopupMenu:
	get: return get_popup()

#--------------------------------------------------------------------------------------------------
func _ready():
	about_to_popup.connect(init_menubutton)
	popup.id_pressed.connect(menubutton_call)
	
#--------------------------------------------------------------------------------------------------
func init_menubutton():
	popup.clear(true)
	popup.add_item("New Project", Menu.NEW_PROJECT)
	popup.add_item("Save Project", Menu.SAVE_PROJECT)
	popup.add_item("Save Project As...", Menu.SAVE_PROJECT_AS)
	popup.add_item("Open Project", Menu.OPEN_PROJECT)
	popup.add_item("Open Project Folder", Menu.PROJECT_FOLDER)
	
	var recents = FileManager.get_recent_list()
	if recents:
		var current_project = project_ctr.get_project()
		var submenu := PopupMenu.new()
		var index = 0
		for file_path in recents:
			if not AssetUtils.is_valid_project_path(file_path):
				continue
			var title = file_path
			var meta = JsonHelper.load_meta(file_path)
			var item_datas = meta.get("item_datas")
			if item_datas:
				title = "%s"%[item_datas[0].title]
			submenu.add_item(title)
			if file_path == current_project.get_path():
				submenu.set_item_as_checkable(index, true)
				submenu.set_item_checked(index, true)
			index += 1
		submenu.index_pressed.connect(open_recent)
		popup.add_submenu_node_item("Open Recent", submenu, Menu.OPEN_RECENT)
		
	popup.add_separator()
	popup.add_item("Setting", Menu.SETTING)
	popup.set_item_disabled(popup.get_item_index(Menu.SETTING), true)
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
			project_changed.emit(current_project)
				
		Menu.SAVE_PROJECT_AS:
			save_project_as(current_project)
			project_changed.emit(current_project)
		
		Menu.PROJECT_FOLDER:
			OS.shell_open(ProjectSettings.globalize_path(AssetUtils.get_root_path()))
		Menu.QUTI:
			quit_request.emit()

#--------------------------------------------------------------------------------------------------
func gdc_file_dialog(title:String, mode:DisplayServer.FileDialogMode) -> Array:
	var gdc_filter = "*.%s"%AssetUtils.GDC_EXTENSION
	return Utils.file_dialog(title, [gdc_filter], mode)

#---------------------------------------------------------------------------------------------------
func quick_open():
	var recent = FileManager.get_recent_list()
	var open_file = ""
	var project
	for file in recent:
		if not FileAccess.file_exists(file):
			continue
		if file.get_extension() != AssetUtils.GDC_EXTENSION:
			continue
		open_file = file
		break
	if FileAccess.file_exists(open_file):
		project = FileManager.open_project(open_file)
	if not project:
		project = FileManager.new_project(AssetUtils.new_project_path())
	project_changed.emit(project)

#---------------------------------------------------------------------------------------------------
func save_current() -> bool:
	# 如果想继续后续的操作返回 true 否则返回 false
	var current_project = project_ctr.get_project()
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
	var file_path = AssetUtils.new_project_path()
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
	if not AssetUtils.is_valid_project_path(file_path):
		return 
	var project = FileManager.open_project(file_path)
	if project:
		project_changed.emit(project)

#---------------------------------------------------------------------------------------------------
func open_recent(index:int):
	var files = FileManager.get_recent_list() # save_current 之前调用因为recent list 会被改变
	if files.size() <= index:
		return 
	var file_path = files[index]
	if not await save_current():
		return 
	if not FileAccess.file_exists(file_path):
		return 
	if not AssetUtils.is_valid_project_path(file_path):
		return 
	var project = FileManager.open_project(file_path)
	if project:
		project_changed.emit(project)

#--------------------------------------------------------------------------------------------------
func save_project(project:BaseItem) -> Error:
	# 如果默认保存路径存在就返回 OK 
	var file_path = project.get_path()
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
	if file_path.get_extension() != AssetUtils.GDC_EXTENSION:
		file_path += ".%s"%AssetUtils.GDC_EXTENSION
	project.set_path(file_path)
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
	

		
