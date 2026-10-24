shader_type canvas_item;

// Captura los tiles y nodos dibujados justo debajo del ColorRect
uniform sampler2D textura_pantalla : hint_screen_texture, filter_nearest;

uniform vec4 color_agua : source_color = vec4(0.08, 0.35, 0.47, 1.0);
uniform vec4 color_ola : source_color = vec4(0.15, 0.45, 0.60, 1.0);
uniform float velocidad = 1.5;
uniform float frecuencia_olas = 20.0;
uniform float amplitud = 0.03;
uniform float transparencia : hint_range(0.0, 1.0) = 0.6;

// Nueva variable para controlar cuánto se deforma el fondo
uniform float fuerza_refraccion = 0.03; 

uniform float amplitud_borde = 0.03;
uniform float frecuencia_borde = 15.0;
uniform float velocidad_borde = 2.0;

void fragment() {
    vec2 uv = UV;
    
    // 1. Cálculo del oleaje base
    float ola_x = sin(uv.y * frecuencia_olas + TIME * velocidad) * amplitud;
    float ola_y = cos(uv.x * frecuencia_olas + TIME * (velocidad * 0.8)) * amplitud;
    float patron = sin((uv.x + ola_x) * frecuencia_olas) * cos((uv.y + ola_y) * frecuencia_olas);
    
    // 2. Distorsión de la textura de fondo usando SCREEN_UV
    vec2 uv_distorsionada = SCREEN_UV + vec2(ola_x, ola_y) * fuerza_refraccion;
    vec4 color_fondo = texture(textura_pantalla, uv_distorsionada);
    
    // 3. Mezcla del color del agua y el fondo distorsionado
    vec4 color_superficie = mix(color_agua, color_ola, smoothstep(0.0, 0.5, patron));
    vec4 color_final = mix(color_fondo, color_superficie, transparencia);
    
    // 4. Máscaras de recorte para el oleaje superior e inferior
    float limite_superior = sin(uv.x * frecuencia_borde + TIME * velocidad_borde) * amplitud_borde + amplitud_borde;
    float limite_inferior = 1.0 - (sin(uv.x * frecuencia_borde - TIME * velocidad_borde) * amplitud_borde + amplitud_borde);
    
    float mascara_superior = smoothstep(limite_superior - 0.005, limite_superior + 0.005, uv.y);
    float mascara_inferior = smoothstep(limite_inferior + 0.005, limite_inferior - 0.005, uv.y);
    
    // 5. Salida final (el canal Alpha lo controlan únicamente las máscaras de los bordes)
    COLOR = vec4(color_final.rgb, mascara_superior * mascara_inferior);
}