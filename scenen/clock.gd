extends PanelContainer

@onready var label_time = %LabelTime
@onready var spin_box_time = %SpinBoxTime
@onready var button_start = %ButtonStart
@onready var button_pause = %ButtonPause
@onready var button_stop = %ButtonStop
@onready var progress_bar_time = %ProgressBarTime

var total_time:float = 0
var time:float = 0:  # s
	set(value):
		time = value
		var mint = int(floor(time)/60.0)
		var secd = floor(time) - mint*60
		label_time.text = "%02d : %02d"%[mint, secd]
		progress_bar_time.value = time
		progress_bar_time.max_value = total_time
		
var started := false
var paused := false


func _ready():
	spin_box_time.value_changed.connect(func(v):
		AssetUtils.save_configs(AssetUtils.S_SETTINGS, AssetUtils.K_COUNTDOWN_TIME, spin_box_time.value)
	)
	
	button_start.pressed.connect(func():
		if paused:
			button_start.hide()
			button_pause.show()
			paused = false
			started = true
		if not started:
			started = true
			total_time = spin_box_time.value*60
			time = total_time
			button_start.hide()
			spin_box_time.hide()
			progress_bar_time.show()
			button_pause.show()
			button_stop.show()
			label_time.show()
	)
	button_pause.pressed.connect(func():
		started = false
		paused = true
		
		button_start.show()
		button_pause.hide()
		
	)
	button_stop.pressed.connect(func():
		started = false
		paused = false
		total_time = 0
		time = 0
		
		button_start.show()
		spin_box_time.show()
		button_pause.hide()
		button_stop.hide()
		progress_bar_time.hide()
		label_time.hide()
	)
	button_start.show()
	spin_box_time.show()
	label_time.hide()
	progress_bar_time.hide()
	button_pause.hide()
	button_stop.hide()
	total_time = 0
	time = 0
	
	spin_box_time.value = AssetUtils.get_configs(AssetUtils.S_SETTINGS, AssetUtils.K_COUNTDOWN_TIME, 40)
	
func _process(delta):
	if not started:
		return 
	if time <= 0:
		button_stop.pressed.emit()
		return 
	time -= delta
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
