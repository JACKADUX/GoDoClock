extends GutTest

func test_init():
	assert_true(true, "test init")

class TestProjectDataController extends GutTest:
	
	
	func test_init():
		var pdc = ProjectDataContoller.new()
		assert_is(pdc.get_project_data(), ProjectDataContoller.ProjectData, "应该有默认值")
	
	func test_create_fn():
		var pdc = ProjectDataContoller.new()
		var project := pdc.get_project_data()
		var todo = project.create_fn.call(ProjectDataContoller.Type.TodoData)
		assert_is(todo, ProjectDataContoller.TodoData, "创建Todo类型")
		assert_eq(todo.get_parent(), null, "没有父级")
		
		var todo2 = project.new_todo_data("test")
		assert_is(todo2, ProjectDataContoller.TodoData, "创建Todo类型")
		assert_eq(todo2.get_parent(), project, "默认被添加父级")
		assert_eq(todo2.get_title(), "test", "默认赋值")

	func test_todo_data():
		var pdc = ProjectDataContoller.new()
		var todo = pdc.create(ProjectDataContoller.Type.TodoData) as ProjectDataContoller.TodoData
		assert_typeof(todo.datetime, TYPE_DICTIONARY, "字典")
		assert_eq(todo.get_datetime(), null, "默认返回空")
		gut.p(todo.get_datetime())
		todo.update_current_datetime()
		assert_typeof(todo.get_datetime(), TYPE_STRING, "如果时间存在，应该默认返回字符形式")
		gut.p(todo.get_datetime())
		

class TestPlayGround extends GutTest:
	func test_any():
		pass
		



















