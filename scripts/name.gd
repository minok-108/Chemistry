extends Node

var name_prefix = ["$Cyclo"]
var name_roots = ["$Meth", "$Eth", "$Prop", "$But", "$Pent", "$Hex", "$Hept", "$Oct", "$Non", "$Dec"]
var name_suffixes = ["$ane", "$ene", "$yne", "$anol", "$anon", "$anal"]

var name_whole = ["$Benzene"]

var last_sub: Dictionary

func find_radical(sub, value):
	var number_of_radical = 0
	for i in range(len(sub.radicals)):
		for j in range(len(sub.radicals[i])):
			var radical = sub.radicals[i][j]
			if radical != null:
				if radical.value == value:
					number_of_radical = i
	
	return number_of_radical

func is_counting_with_start(sub):
	if sub.type == "Alkene" or sub.type == "Alkyne":
		if sub.length % 2 != 0 or sub.double_place != sub.length / 2:
			return sub.double_place <= sub.length / 2
	
	var min_pos = 1000
	var ammount_of_min_pos = 0
	
	var max_pos = -1000
	var ammount_of_max_pos = 0
	
	for i in range(len(sub.radicals)):
		for j in range(len(sub.radicals[i])):
			var radical = sub.radicals[i][j]
			if radical != null:
				if radical.value == "O" or radical.value == "OH":
					if sub.type == "Aldehyde":
						return i == 0
					
					return sub.length / 2 > i
				
				if i == min_pos:
					ammount_of_min_pos += 1
				
				if i == max_pos:
					ammount_of_max_pos += 1
				
				if i < min_pos:
					min_pos = i
					ammount_of_min_pos = 1
				if i > max_pos:
					max_pos = i
					ammount_of_max_pos = 1
	
	if sub.length - max_pos == min_pos + 1:
		return ammount_of_min_pos > ammount_of_max_pos
	
	return sub.length - max_pos >= min_pos + 1


func count_all_radicals(sub):
	var ammount_of_radicals = 0
	for i in range(len(sub.radicals)):
		for j in range(len(sub.radicals[i])):
			if sub.radicals[i][j] != null:
				ammount_of_radicals += 1
	
	return ammount_of_radicals


func set_element_name(sub):
	last_sub = sub.duplicate(true)
	var element_name_base = ""
	
	var element_name_radicals = ""
	
	var position_of_radicals = {
		"methyl": [],
		"chlorine": []
	}
	
	var counting_with_start = is_counting_with_start(sub)
	
	#Основа
	match sub.type:
		"Alkane":
			element_name_base = tr(name_roots[sub.length - 1]) + tr(name_suffixes[0])
		
		"Alkene", "Alkyne":
			var suffix = 0
			if sub.type == "Alkene":
				suffix = 1
			elif sub.type == "Alkyne":
				suffix = 2
			
			if sub.length == 2:
				element_name_base = tr(name_roots[sub.length - 1]) + tr(name_suffixes[suffix])
			else:
				if counting_with_start:
					element_name_base = tr(name_roots[sub.length - 1]) + tr(name_suffixes[suffix]) \
						+ " - " + str(sub.double_place)
				else:
					element_name_base = tr(name_roots[sub.length - 1]) + tr(name_suffixes[suffix]) \
						+ " - " + str(sub.length - sub.double_place)
		
		"Alcohol":
			var number_of_alcohol = find_radical(sub, "OH")
			
			if counting_with_start:
				element_name_base = tr(name_roots[sub.length - 1]) + tr(name_suffixes[3]) \
					+ " - " + str(number_of_alcohol + 1)
			else:
				element_name_base = tr(name_roots[sub.length - 1]) + tr(name_suffixes[3]) \
					+ " - " + str(sub.length - number_of_alcohol)
		
		"Ketone":
			var number_of_ketone = find_radical(sub, "O")
			
			if counting_with_start:
				element_name_base = tr(name_roots[sub.length - 1]) + tr(name_suffixes[4]) \
					+ " - " + str(number_of_ketone + 1)
			else:
				element_name_base = tr(name_roots[sub.length - 1]) + tr(name_suffixes[4]) \
					+ " - " + str(sub.length - number_of_ketone)
		
		"Cycloalkane":
			element_name_base = tr(name_prefix[0]) + tr(name_roots[sub.length - 1]) \
			+ tr(name_suffixes[0])
		
		"Benzene":
			element_name_base = tr(name_whole[0])
		
		"Aldehyde":
			element_name_base = tr(name_roots[sub.length - 1]) + tr(name_suffixes[5])
		
		"EmptySet":
			element_name_base = tr("$Empty_set")
	
	#Радикалы
	
	if count_all_radicals(sub) != 0:
		match sub.type:
			"Alkane", "Alkene", "Alkyne", "Ketone", "Alcohol", "Aldehyde":
				if counting_with_start:
					for i in range(len(sub.radicals)):
						for j in range(len(sub.radicals[i])):
							var radical = sub.radicals[i][j]
							if radical != null:
								if radical.value == "CH" + G.indexs[3]:
									position_of_radicals.methyl.append(i + 1)
								elif radical.value == "Cl":
									position_of_radicals.chlorine.append(i + 1)
				
				else:
					for i in range(len(sub.radicals)):
						for j in range(len(sub.radicals[i])):
							var radical = sub.radicals[i][j]
							if radical != null:
								if radical.value == "CH" + G.indexs[3]:
									position_of_radicals.methyl.append(sub.length - i)
								elif radical.value == "Cl":
									position_of_radicals.chlorine.append(sub.length - i)
			
			"Cycloalkane", "Benzene":
				var max = -1000
				var pos_max = 0
				for i in range(len(sub.radicals)):
					var ammount_of_radicals = G.count_radicals(sub, i)
					if max < ammount_of_radicals:
						max = ammount_of_radicals
						pos_max = i
				
				for i in range(len(sub.radicals)):
					for j in range(len(sub.radicals[i])):
						var radical = sub.radicals[i][j]
						
						var pos = (pos_max + 1 - i)
						
						if pos <= 0: pos += sub.length
						
						if radical != null:
							if radical.value == "CH" + G.indexs[3]:
								position_of_radicals.methyl.append(pos)
							elif radical.value == "Cl":
								position_of_radicals.chlorine.append(pos)
		
		for radical_type in position_of_radicals:
			if len(position_of_radicals[radical_type]) != 0:
				position_of_radicals[radical_type].sort()
				for i in range(len(position_of_radicals[radical_type])):
					element_name_radicals += str(position_of_radicals[radical_type][i])
					if i != len(position_of_radicals[radical_type]) - 1:
						element_name_radicals += ", "
				
				if radical_type == "methyl":
					element_name_radicals += " - (" + str(len(position_of_radicals[radical_type])) \
						+ ")" + tr("$Methyl")
				elif radical_type == "chlorine":
					element_name_radicals += " - (" + str(len(position_of_radicals[radical_type])) \
						+ ")" + tr("$Chlorine")
				
				if radical_type == "methyl" and len(position_of_radicals.chlorine) != 0:
					element_name_radicals += " - "
	
	var prop = set_element_properties(sub)
	
	
	get_parent().get_node("UI/Label").text = prop
	
	get_parent().get_node("UI/Top/Panel/HBoxContainer/LabelName").text = tr("$Name") + ": " +  element_name_radicals + element_name_base

func update_name():
	if len(last_sub) != 0:
		set_element_name(last_sub)

func remove_element_name():
	last_sub = {}
	get_parent().get_node("UI/Top/Panel/HBoxContainer/LabelName").text = ""

















func set_element_properties(sub):
	var consistence = ""; var color = ""; var odor = ""; var flame = ""; var organic_solubility = ""; var water_colubility = ""
	match sub.type:
		"Alkane":
			if sub.length < 5:
				consistence = "$gase"
				color = "$absent"
				odor = "$absent"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
			elif sub.length < 16:
				consistence = "$oily_liquid"
				color = "$absent"
				odor = "$pungent_gasoline"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
			else:
				consistence = "$waxy"
				color = "$slightly_yellowish"
				odor = "$faint_smell_of_gasoline"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
		"Alkene":
			if sub.length < 5:
				consistence = "$gase"
				color = "$absent"
				if sub.length < 4:
					odor = "$faint_floral"
				else:
					odor = "$oily_liquid"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
			elif sub.length < 16:
				consistence = "$volatile_liquid"
				color = "$absent"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
			else:
				consistence = "$solid"
				color = "$absent"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
		"Alkyne":
			if sub.length < 5:
				consistence = "$gase"
				color = "$absent"
				odor = "$absent"
				flame = "$bright_smoky"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
			elif sub.length < 16:
				consistence = "$volatile_liquid"
				color = "$absent"
				flame = "$bright_smoky"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
			else:
				consistence = "$solid"
				color = "$absent"
				odor = "$absent"
				flame = "$bright_smoky"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
		"Alcohol":
			if sub.length < 11:
				consistence = "$liquid"
				color = "$absent"
				odor = "$burning_alcoholic"
				if sub.length == 1:
					flame = "$green"
				elif sub.length == 2:
					flame = "$blue"
				organic_solubility = "$yes"
				if sub.length < 4 or (sub.length == 4 and sub.radicals[1][0] != null and sub.radicals[1][1] != null and sub.radicals[1][0].value == "CH₃" and sub.radicals[1][1].value == "CH₃"):
					water_colubility = "$yes"
				elif sub.length < 10:
					water_colubility = "$almost_not"
				else:
					water_colubility = "$no"
			else:
				consistence = "$solid"
				color = "$absent"
				odor = "$absent"
				flame = "$yellowish"
				organic_solubility = "$yes"
				water_colubility = "$no"
		"Ketone":
			if sub.length < 5:
				consistence = "$volatile_liquid"
				color = "$absent"
				if sub.length == 3:
					odor = "$strong_smell_of_nail_polish"
				else:
					odor = "$fruity"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$yes"
			else:
				consistence = "$solid"
				color = "$yellowish"
				odor = "$fruiy"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$no"
		"Cycloalkane":
			if sub.length < 5:
				consistence = "$gase"
				color = "$absent"
				odor = "$absent"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
			elif sub.length < 16:
				consistence = "$oily_liquid"
				color = "$absent"
				odor = "$pungent_gasoline"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
			else:
				consistence = "$waxy"
				color = "$slightly_yellowish"
				odor = "$faint_smell_of_gasoline"
				flame = "$pale_blue"
				organic_solubility = "$yes"
				water_colubility = "$almost_not"
		"Benzene":
			consistence = "$liquid"
			color = "$absent"
			odor = "$peculiar_pungent"
			flame = "$bright_smoky"
			organic_solubility = "$yes"
			water_colubility = "$no"
	
	return tr("$consistence") + ": " + tr(consistence) + '\n' + tr("$color") + ": " + tr(color) + '\n' + tr("$odor") + ": " + tr(odor) + '\n' + tr("$flame") + ": " + tr(flame) + '\n' + tr("$organic_solubility") + ": " + tr(organic_solubility) + '\n' + tr("$water_solubility") + ": " + tr(water_colubility)

