// Cena de abertura: toca uma vez no jogo, assim que a Nexa entra no 1º andar
if (!variable_global_exists("intro_feita")) global.intro_feita = false;
if (!global.intro_feita) {
	global.intro_feita = true;
	iniciar_dialogo("intro", "nada", -1);
}
instance_destroy();
