extends Control

@onready var confirmation_dialog = $ConfirmationDialog

# Called when the node enters the scene tree for the first time.
func _ready():
	confirmation_dialog.add_button("Discord1", true, "Discord2")
	confirmation_dialog.custom_action.connect(func(n):
		print(n)
	)
	confirmation_dialog.canceled.connect(func():
		print(123)
		)
	confirmation_dialog.show()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
