extends GutTest

func test_init():
	assert_true(true, "test init")

class TestProjectController extends GutTest:
	
	## [Hierarchy相关]
	func test_new_item():
		var ctr := ProjectContoller.new()
		var project := ctr.get_project()
		var undoredo :UndoRedo = ctr._undoredo
		var action_name = "NewItem"
	
		ctr.undoredo_warp(action_name, func():
			for i in range(10):
				var group = ItemFactory.new_group()
				BaseHierarchy.undoredo_add(undoredo, group, project)
		)	

		assert_eq(project.get_child_count(), 10, "创建十个子对象")
		undoredo.undo()
		assert_eq(project.get_child_count(), 0, "撤销后子对象应该为0")
		undoredo.redo()
		assert_eq(project.get_child_count(), 10, "重做后子对象应该为10")
		undoredo.undo()
		
		ctr.undoredo_warp(action_name, func():
			for i in range(10):
				var group = ItemFactory.new_group()
				BaseHierarchy.undoredo_add(undoredo, group, project)
		)
		ctr.undoredo_warp(action_name, func():
			for i in range(10):
				var group = ItemFactory.new_group()
				BaseHierarchy.undoredo_add(undoredo, group, project)
		)
		assert_eq(project.get_child_count(), 20, "创建十个子对象")
		undoredo.undo()
		assert_eq(project.get_child_count(), 10, "创建十个子对象")

	func test_delet_item():
		var ctr := ProjectContoller.new()
		var project := ctr.get_project()
		var undoredo :UndoRedo = ctr._undoredo
		var action_name = "DeletItem"
		ctr.undoredo_warp(action_name, func():
			for i in range(10):
				var group = ItemFactory.new_group()
				BaseHierarchy.undoredo_add(undoredo, group, project)
		)	
		assert_eq(project.get_child_count(), 10, "创建十个子对象")
		ctr.undoredo_warp(action_name, func():
			for group in project.get_children():
				BaseHierarchy.undoredo_remove(undoredo, group)
		)
		assert_eq(project.get_child_count(), 0, "删除十个子对象")
		undoredo.undo()
		assert_eq(project.get_child_count(), 10, "撤销最后删除的对象")
		undoredo.redo()
		assert_eq(project.get_child_count(), 0, "重做删除十个子对象")
	
	func test_hierarchy():
		# 讨论 hierarchy 时，一个前提就是对象已经在组内
		# 所以本质与select一样是上层对象的整体状态属性
		# 但整体状态直接设置会比较多余 （很多时候只是一个物体改变层级）
		var ctr := ProjectContoller.new()
		var undoredo :UndoRedo = ctr._undoredo
		var project := ctr.get_project()

		var g1 = ItemFactory.new_group() as BaseItem.GroupItem
		var g2 = ItemFactory.new_group() as BaseItem.GroupItem
		var g3 = ItemFactory.new_group() as BaseItem.GroupItem
		
		project.add_child(g1)
		project.add_child(g2)
		project.add_child(g3)
				
		assert_eq(g1.get_index(), 0, "在最前面")
		BaseHierarchy.undoredo_drag(undoredo, [g1], g3, BaseHierarchy.DragDrop.AFTER)
		assert_eq(g1.get_index(), 2, "排到最后")
		

		BaseHierarchy.undoredo_drag(undoredo, [g2], g1, BaseHierarchy.DragDrop.UNDER)

		assert_eq(project.get_child_count(), 2, "数量变少一个")
		assert_eq(g1.get_child_count(), 1, "一个")
		assert_eq(g2.get_index(), 0, "第一个")
	
	## [Property相关]
	func test_single_property():
		# 属性只与对象本身有关系则可以使用这种方式
		var ctr := ProjectContoller.new()
		var project := ctr.get_project()
		var undoredo :UndoRedo = ctr._undoredo
		
		var group := ItemFactory.new_group() as BaseItem.GroupItem
		assert_eq(group.get_type(), ItemFactory.ItemType.Group, "类型一致")
		assert_ne(group.get_type(), ItemFactory.ItemType.Todo, "类型一致")
		
		var change_property_start = func(object:Object, property_name:String, mode:=UndoRedo.MERGE_DISABLE):
			undoredo.create_action("ChangeProperty", mode)
			undoredo.add_undo_property(object,property_name, object.get(property_name))
			
		var change_property_end = func(object:Object, property_name:String):
			undoredo.add_do_property(object,property_name, object.get(property_name))
			undoredo.commit_action()
		
		group._debug_value = 5
		
		change_property_start.call(group, "_debug_value")
		for i in range(40):
			group._debug_value += 1
		change_property_end.call(group, "_debug_value")
			
		assert_eq(group._debug_value, 45, "属性结果一致")
		undoredo.undo()
		assert_eq(group._debug_value, 5, "属性结果一致")
		undoredo.redo()
		assert_eq(group._debug_value, 45, "属性结果一致")
		
		## muilty_signal_property
		for i in range(10):
			var g := ItemFactory.new_group() as BaseItem.GroupItem
			g._debug_value = i
			project.add_child(g)
		
		ctr.undoredo_warp("ChangeProperty", func():
			for g in project.get_children():
				change_property_start.call(g, "_debug_value")
				for i in range(40):
					g._debug_value += 1
				change_property_end.call(g, "_debug_value")
		)
		for g in project.get_children():
			assert_eq(g._debug_value, g.get_index() + 40, "偏移了40")
		undoredo.undo()
		for g in project.get_children():
			assert_eq(g._debug_value, g.get_index(), "撤回为各自的index")
		
		## 
		var some_func_with_undoredo = func():
			for g in project.get_children():
				g._debug_value += 1
		
		undoredo.create_action("ChangeProperty")
		# start
		for g in project.get_children():
			undoredo.add_undo_property(g, "_debug_value", g.get("_debug_value"))
		# process
		for i in 40:
			some_func_with_undoredo.call()
		# end
		for g in project.get_children():
			undoredo.add_do_property(g, "_debug_value", g.get("_debug_value"))
		undoredo.commit_action()
		
		for g in project.get_children():
			assert_eq(g._debug_value, g.get_index() + 40, "偏移了40")
		undoredo.undo()
		for g in project.get_children():
			assert_eq(g._debug_value, g.get_index(), "撤回为各自的index")
		
	func test_collection_property():
		## NOTE:群组性的属性设置时需要通过列表来设置, 也就是说要考虑到整体状态的变化
		# 群组性的数值 
		# 这里的 _debug_value 相当于 select
		var ctr := ProjectContoller.new()
		var project := ctr.get_project()
		var undoredo :UndoRedo = ctr._undoredo
		
		for i in range(10):
			var group = ItemFactory.new_group()
			BaseHierarchy.undoredo_add(undoredo, group, project)
		
		var deselect_all_fn = func():
			for group:BaseItem in project.get_children():
				group._debug_value = 0
		var select_fn = func(item, value:bool):
			item._debug_value = int(value)
		var selects_fn = func(): return project.get_children().filter(func(g): return g._debug_value) 
		
		var common_select_fn = func(select_list:Array):
			deselect_all_fn.call()
			for item in select_list:
				select_fn.call(item, true)
		assert_eq(selects_fn.call().size(), 0, "没有选择")
		var selection = selects_fn.call()  # NOTE: undoredo要用的数据在方法外获取再传进去 否则会出错
		# start
		undoredo.create_action("Select")
		undoredo.add_undo_method(common_select_fn.bind(selection))
		# process
		selection = project.get_children().filter(func(i): return i.get_index() < 5)
		common_select_fn.call(selection)
		# end
		undoredo.add_do_method(common_select_fn.bind(selection))
		undoredo.commit_action()
		
		assert_eq(selects_fn.call().size(), 5, "有选择")
		undoredo.undo()
		assert_eq(selects_fn.call().size(), 0, "没有选择")
		undoredo.redo()
		assert_eq(selects_fn.call().size(), 5, "有选择")
		
class TestFileManager extends GutTest:
	var file_path = "user://fm_test.%s"%FileManager.GDC_EXTENSION
	func test_new():
		if FileAccess.file_exists(file_path):
			DirAccess.remove_absolute(file_path)
		var project = FileManager.new_project(file_path)
		assert_eq(project.get_title(), file_path, "路径保存在名称中")
		assert_true(project is BaseItem, "类型确认")
		assert_true(FileAccess.file_exists(file_path), "创建时直接保存")

	func test_save_and_open():
		var project = FileManager.open_project(file_path)
		for child in project.get_children():
			project.remove_child(child)
		assert_eq(project.get_child_count(), 0, "应该没有子对象")
		project.add_child(ItemFactory.new_group())
		project.add_child(ItemFactory.new_group())
		FileManager.save_project(project)
		var reopen_project = FileManager.open_project(file_path)
		assert_eq(reopen_project.get_child_count(), 2, "应该只有两个子对象")

	func test_recent_list():
		FileManager.recent_list.clear()
		FileManager.open_project(file_path, true)
		FileManager.open_project(file_path, true)
		FileManager.open_project(file_path, true)
		assert_eq(FileManager.recent_list.size(), 1, "应该只有1个对象")
		for i in 15:
			FileManager.add_to_recent_list(str(i))
		assert_eq(FileManager.recent_list.size(), FileManager.MAX_NUMBER, "应该只有10个对象")
		FileManager.add_to_recent_list("10")
		assert_eq(FileManager.recent_list[0], "10", "移到首位")
		assert_eq(FileManager.recent_list.count("10"), 1, "不会重复")
		FileManager.clear_recent_list()
		assert_eq(FileManager.recent_list.size(), 0, "应该没有对象")
		
class TestMainMenu extends GutTest:
	
	func test_button_new():
		var file_path = "user://fm_test.%s"%FileManager.GDC_EXTENSION
		if FileAccess.file_exists(file_path):
			DirAccess.remove_absolute(file_path)
		var main_menu = partial_double(MainMenu).new()
		watch_signals(main_menu)
		stub(main_menu, 'gdc_file_dialog').to_return([file_path])
		get_tree().root.add_child(main_menu)
		main_menu.menubutton_call(main_menu.Menu.NEW_PROJECT)
		assert_signal_emitted(main_menu, 'new_project')

	
