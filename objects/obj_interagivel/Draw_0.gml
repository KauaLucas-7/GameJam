// Aviso "[E] ..." quando a Nexa está perto
if (nexa_perto() && !instance_exists(obj_dialogo)) {
	texto_mundo(x, y + prompt_y, texto_prompt);
}
