// Mesma resolução de interface da batalha e da oficina (480x270)
display_set_gui_size(480, 270);

linhas = [];
i = 0;
acao = "nada";
sala = -1;
espera = 1;          // ignora a tecla do frame em que o diálogo abriu

// --- Cutscene ---
letras = 0;          // texto aparecendo letra por letra
vel_letras = 1.1;
linha_iniciada = -1; // última linha que já disparou seus efeitos
barras = 0;          // barras de cinema (narração)
ret_anim = 0;        // retrato entrando
falante_ant = "";
tremor = 0;          // efeito "tremer"
clarao = 0;          // efeito "flash"
abrir = 0;           // caixa abrindo
