extends Node

func human_time(i_time : float) -> String:
	var time_h_seconds = fmod(i_time, 1) * 1000
	var time_seconds = fmod(i_time, 60)
	var time_minutes = fmod(i_time, 3600) / 60
	var time_hour = fmod(fmod(i_time, 86400) / 3600, 24)
	
	return "%02d:%02d:%02d.%03d" % [time_hour, time_minutes, time_seconds, time_h_seconds]
