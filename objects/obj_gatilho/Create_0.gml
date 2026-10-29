// tipo: "luta" (padrão) dispara ao encostar na Nexa
//       "intro" dispara sozinho ao entrar na sala (só uma vez no jogo)
// Para trocar, na Creation Code da instância: tipo = "intro";
if (!variable_instance_exists(id, "tipo")) tipo = "luta";

// O andar sai do nome da sala: rm_andar1 -> 1, rm_andar2 -> 2 ...
andar_alvo = real(string_digits(room_get_name(room)));
ativado = false;

if (variable_global_exists("vencidos") && variable_struct_exists(global.vencidos, "a" + string(andar_alvo))) {
	instance_destroy();
	exit;
}
