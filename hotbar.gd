extends VBoxContainer

var current_slot = 0

func switch_slot(slot: int):
	if slot != current_slot:
		# ....
		current_slot = slot

	var i = 0
	for hb_slot in self.get_children():
		if hb_slot is not Panel: continue
		hb_slot.modulate = Color.YELLOW if i == slot else Color.WHITE
		i += 1