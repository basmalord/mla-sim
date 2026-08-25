extends Node2D

signal end_of_the_line
signal spawning_new_vdt_word

#need a station manager that contains a dictionary of station nodes as keys, the values for which are an array of any stations that that station leeds to
#Any train can be made with a location in mind, location passed to a function that utilises the above to generate the correct order of stations to go through.
#station manager must contain the behaviour to get to the other stations, so that when the train's collision shape comes into contact with the station gate, 
#then the correct behaviour can be judged


@export var station_to_station_paths_dict: Dictionary = {"prompt_station":
		{"north": "", "south": "", "east": "junct_1", "west": ""},
	"junct_1": 
		{"north": "goals_station_1", "south": "", "east": "junct_2", "west": "prompt_station"},
	"goals_station_1": 
		{"north": "", "south": "junct_1", "east": "", "west": ""},
	"goals_station_2":
		{"north": "user_sat_label_station", "south": "", "east": "", "west": ""},
	"user_sat_label_station":
		{"north": "", "south": "goals_station_2", "east": "", "west": ""},
	"junct_2":
		{"north": "generator_station", "south": "", "east": "junct_3", "west": "junct_1"},
	"junct_3": 
		{"north": "options_station_1", "south": "", "east": "", "west": "junct_2"},
	"junct_4":
		{"north": "", "south": "options_station_2", "east": "", "west": "probability_label_station"},
	"options_station_1":
		{"north": "", "south": "junct_3", "east": "", "west": ""},
	"options_station_2":
		{"north": "junct_4", "south": "", "east": "", "west": ""},
	"probability_label_station":
		{"north": "", "south": "", "east": "junct_4", "west": ""},
	"generator_station":
		{"north": "", "south": "junct_2", "east": "", "west": ""}
		} #should take structure: Station: [north_station,south_station,east_station,west_station]

var station_to_station_new_paths_dict: Dictionary = {
	"prompt_station":
		{
			"north": [],
			"south": [],
			"east": [
				"junct_1",
				"junct_2",
				"generator_station",
				"junct_3",
				"options_station_1",
				"goals_station_1"
			],
			"west": []
		},

	"junct_1":
		{
			"north": [
				"goals_station_1"
			],
			"south": [],
			"east": [
				"junct_2",
				"generator_station",
				"junct_3",
				"options_station_1"
			],
			"west": [
				"prompt_station"
			]
		},

	"goals_station_1":
		{
			"north": [],
			"south": [
				"junct_1",
				"prompt_station",
				"junct_2",
				"generator_station",
				"junct_3",
				"options_station_1"
			],
			"east": [],
			"west": []
		},

	"goals_station_2":
		{
			"north": [
				"user_sat_label_station"
			],
			"south": [],
			"east": [],
			"west": []
		},

	"user_sat_label_station":
		{
			"north": [],
			"south": [
				"goals_station_2"
			],
			"east": [],
			"west": []
		},

	"junct_2":
		{
			"north": [
				"generator_station"
			],
			"south": [],
			"east": [
				"junct_3",
				"options_station_1"
			],
			"west": [
				"junct_1",
				"prompt_station",
				"goals_station_1"
			]
		},

	"junct_3":
		{
			"north": [
				"options_station_1"
			],
			"south": [],
			"east": [],
			"west": [
				"junct_2",
				"junct_1",
				"prompt_station",
				"goals_station_1",
				"generator_station"
			]
		},

	"junct_4":
		{
			"north": [],
			"south": [
				"options_station_2"
			],
			"east": [],
			"west": [
				"probability_label_station"
			]
		},

	"options_station_1":
		{
			"north": [],
			"south": [
				"junct_3",
				"junct_2",
				"junct_1",
				"prompt_station",
				"generator_station",
				"goals_station_1"
			],
			"east": [],
			"west": []
		},

	"options_station_2":
		{
			"north": [
				"junct_4",
				"probability_label_station"
			],
			"south": [],
			"east": [],
			"west": []
		},

	"probability_label_station":
		{
			"north": [],
			"south": [],
			"east": [
				"junct_4",
				"options_station_2"
			],
			"west": []
		},

	"generator_station":
		{
			"north": [],
			"south": [
				"junct_2",
				"junct_1",
				"prompt_station",
				"goals_station_1",
				"options_station_1",
				"junct_3"
			],
			"east": [],
			"west": []
		}
}

var stations_id_array: Array[String]
var stations_dict: Dictionary

var predefined_paths: Dictionary = {
	"prompt to goals": [
		"prompt_station", "junct_1", "goals_station_1"
	],
	"goals2 to US label": [
		"goals_station_2", "user_sat_label_station"
	],
	"goals1 to generator": [
		"goals_station_1","junct_1", "junct_2", "generator_station"
	],
	"generator to prompt": [
		"generator_station", "junct_2", "junct_1", "prompt_station"
	],
	"generator to options1": [
		"junct_2", "junct_3", "options_station_1"
	],
	"options2 to confidence label": [
		"options_station_2", "junct_4", "probability_label_station"
	]
	}

func _ready():
	_set_stations_dict()
	await get_tree().create_timer(1).timeout
	for path in predefined_paths.keys():
		_begin_journey_transfer(path, "testing")
		await get_tree().create_timer(4).timeout

func _continue_journey(station_node: VDTStation, word_node_properties: Array):
	var station_id: String = station_node.station_id
	var word_node_word: String = word_node_properties[0]
	var word_node_path: Array = word_node_properties[1]

func _begin_journey_transfer(path_name: String, string_data: String):
	var new_path: Array = predefined_paths[path_name]
	var spawning_station_id: String = new_path.front()
	var spawning_station: VDTStation = stations_dict[spawning_station_id]
	var word_node_properties: Array = [string_data, new_path]
	emit_signal("spawning_new_vdt_word")
	spawning_station._spawn_word(word_node_properties)

func _set_stations_dict():
	for child in get_children():
		if child is VDTStation:
			var station_id: String = child.station_id
			stations_dict[station_id] = child

func _set_stations_id_array():
	for child in get_children():
		if child is VDTStation:
			stations_id_array.append(child.station_id)

func get_station_paths(station_id: String):
	return station_to_station_new_paths_dict[station_id]

func get_stations_between(start_station: String, destination_station: String):
	var path: Array[String] = []
	var current_station: String = start_station
	while current_station != destination_station:
		var found_destination = false
		for direction in station_to_station_new_paths_dict[current_station]:
			var direction_array: Array = station_to_station_new_paths_dict[current_station][direction]
			if destination_station in direction_array:
				current_station = direction_array[0]
				path.append(current_station)
				found_destination = true
				break
		if !found_destination:
			return []
	return path

func _end_of_the_line(station_id: String): #left to do: test all the paths, then setup colour modulation based on value of data
	emit_signal("end_of_the_line")
