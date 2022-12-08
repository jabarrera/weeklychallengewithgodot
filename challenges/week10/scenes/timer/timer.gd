extends CanvasLayer

var running_timer : bool = false
var time : float = 0


func _ready():
	running_timer = false
	time = 0;

func _process(delta):
	if running_timer:
		time += delta
		$Label.text = TimeConverter.human_time(time)

func start_timer():
	running_timer = true
	
func stop_timer() -> float:
	running_timer = false
	return time
