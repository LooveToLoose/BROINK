
// Press space to start training
if keyboard_check_pressed(vk_space)
	go = true

if !go
	exit;

trainer.NextGeneration()