// Cenário das escadas/corredores (enquanto não há arte de fundo)
depth = 50;   // atrás de tudo, na frente da camada Background
var _n = real(string_digits(room_get_name(room)));
px1 = room_width / 2;    // centro da porta de cima (atualizado no Draw)
px2 = room_width / 2;    // centro da porta de baixo
placa ="ESCADA  ANDAR " + string(_n) + "  >  ANDAR " + string(_n + 1);
