extends Node2D


export var background : Texture = preload("res://common/gfx/background/sky_horizont_bg.webp")
export var city_name : String
export var city_time : String
export var city_weather : String

var http_request : HTTPRequest

var time_request


# Called when the node enters the scene tree for the first time.
func _ready():
	$background.texture = background
	$city_name.text = city_name
	$city_time.text = city_time
	$city_weather.text = city_weather
	


func set_city_image(city_image_name : String):
	var image = load("res://challenges/week12/gfx/cities/" + city_image_name)
	$city_img.texture = image
	
func set_city_weather(city_weather : String):
	$city_weather.text = city_weather

func set_city_time(city_time : String):
	var hour_from_time = int(city_time.substr(11, 2))
	var minutes = Time.get_datetime_dict_from_system().get("minute")

	var city_time_with_minutes = city_time.substr(0, 14) + "%02d" % minutes
	
	if hour_from_time >= 7 and hour_from_time <= 19:
		set_day()
	else:
		set_night()
	
	$city_time.text = city_time_with_minutes
	
	


func _request_completed(result, response_code, headers, body):
	if time_request == null or elapsed_more_one_hour():
	
		var response = parse_json(body.get_string_from_utf8())
		
		var time = response.get("current_weather").get("time")
		var weather = response.get("current_weather").get("weathercode")
		
		set_city_weather(get_weather_from_code(weather))
		set_city_time(time)
		
		time_request = OS.get_unix_time()
	
func get_weather_from_code(weather_code : float) -> String:
	
	if weather_code == 1 or weather_code == 2 or weather_code == 3:
		set_cloudy()
		return "Partly cloudy"
	elif weather_code == 45 or weather_code == 48:
		set_fog()
		return "Fog"
	elif weather_code == 51 or weather_code == 53 or weather_code == 55:
		set_light_rain()
		return "Light rain"
	elif weather_code == 56 or weather_code == 57:
		set_light_rain()
		return "Freezy light rain"
	elif weather_code == 61 or weather_code == 63 or weather_code == 65:
		set_rain()
		return "Rain"
	elif weather_code == 66 or weather_code == 67:
		set_rain()
		return "Freezy rain"
	elif weather_code == 71 or weather_code == 73 or weather_code == 75 or weather_code == 77:
		set_snow()
		return "Snow"
	elif weather_code == 80 or weather_code == 81 or weather_code == 82:
		set_strong_rain()
		return "Strong rain"
	elif weather_code == 85 or weather_code == 86:
		set_strong_snow()
		return "Strong snow"
	else:
		set_clear_sky()
		return "Clear Sky"

func elapsed_more_one_hour():
	if time_request == null:
		return true
		
	var elapse = OS.get_unix_time() - time_request
	
	if (elapse / 60) >= 1:
		return true
	else:
		return false

func get_weather_info(latitude : float, longitude : float):
	
	if elapsed_more_one_hour():
		var parameters = "?latitude=%s&longitude=%s&current_weather=true&timezone=auto" % \
			[str(latitude), str(longitude)]
			
		if not http_request.is_connected("request_completed", self, "_request_completed"):
			http_request.connect("request_completed", self, "_request_completed")
		
		var error = http_request.request("https://api.open-meteo.com/v1/forecast" + parameters)
		
		if error != OK:
			print("Error: " + str(error))

func set_cloudy():
	$cloudy.show()
	$fog.hide()
	
func set_fog():
	$cloudy.hide()
	$fog.show()
	
func set_clear_sky():
	all_weather_off()
	$cloudy.hide()
	$fog.hide()

func set_light_rain():
	all_weather_off()
	set_cloudy()
	$LightRain.emitting = true
	
func set_rain():
	all_weather_off()
	set_cloudy()
	$StrongRain.emitting = true

func set_snow():
	all_weather_off()
	$LightSnow.emitting = true
	
func set_strong_rain():
	all_weather_off()
	$StrongRain.emitting = true
	
func set_strong_snow():
	all_weather_off()
	$StrongSnow.emitting = true

func set_day():
	$night.hide()

func set_night():
	$night.show()

func all_weather_off():
	$LightRain.emitting = false
	$LightSnow.emitting = false
	$StrongRain.emitting = false
	$StrongSnow.emitting = false
