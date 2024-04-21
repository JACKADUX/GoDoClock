class_name Factory

var _factory:={}

func register(type:int, create_fn:Callable):
	_factory[type] = create_fn
	
func unregister(type):
	if type in _factory:
		_factory.erase(type)
		
func create(type:int):
	if _factory.get(type): 
		return _factory[type].call()
