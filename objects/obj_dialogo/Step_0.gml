if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
	i++;
	if (i >= array_length(linhas)) {
		if (acao == "luta" && sala != -1) room_goto(sala);
		if (acao == "creditos") iniciar_dialogo("creditos", "fim", -1);
		if (acao == "fim") game_end();
		instance_destroy();
	}
}
