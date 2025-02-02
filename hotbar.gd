extends VBoxContainer

func switch_slot(slot: int):
	var i = 0
	for hb_slot in self.get_children():
		hb_slot.modulate = Color.WHITE if i == slot else Color.YELLOW
		i += 1