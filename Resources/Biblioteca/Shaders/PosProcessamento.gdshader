shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// --- EFEITO CRT ---
uniform float scanline_count = 300.0;
uniform float scanline_opacidade = 0.1;

// NOVO: Escurece os cantos para simular o vidro curvo da TV (0.0 a 1.0)
uniform float tubo_sombra : hint_range(0.0, 1.0) = 0.3; 

// --- ABERRAÇÃO CROMÁTICA ---
uniform float aberracao_forca = 0.001;

// --- SANGUE (Mantido escondido para o código do Player usar) ---
uniform float sangue_intensidade = 0.0; 
uniform vec4 sangue_cor : source_color = vec4(0.8, 0.0, 0.0, 1.0);

void fragment() {
    // 100% PLANO = O Mouse nunca vai errar o clique!
    vec2 uv = SCREEN_UV; 

    // 1. ABERRAÇÃO CROMÁTICA
    float r = texture(screen_texture, uv + vec2(aberracao_forca * 0.5, 0.0)).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - vec2(aberracao_forca * 0.5, 0.0)).b;
    vec4 cor_base = vec4(r, g, b, 1.0);

    // 2. SCANLINES
    float linha = sin(uv.y * scanline_count * 3.14159);
    linha = mix(1.0, (linha * 0.5 + 0.5), scanline_opacidade);
    cor_base.rgb *= linha; 

    // 3. FAKE CRT TUBE (Ilusão de curvatura nos cantos)
    vec2 dist_centro = abs(uv - 0.5) * 2.0; 
    // Cria uma máscara que só fica forte bem nas pontas da tela
    float mascara_canto = pow(max(dist_centro.x, dist_centro.y), 8.0 - (tubo_sombra * 5.0));
    cor_base.rgb = mix(cor_base.rgb, vec3(0.0), mascara_canto * tubo_sombra);

    // 4. VIGNETTE VERMELHO (Sangue)
    float dist_sangue = distance(uv, vec2(0.5, 0.5));
    float vignette = smoothstep(0.4, 0.7, dist_sangue) * sangue_intensidade;

    COLOR = mix(cor_base, sangue_cor, vignette);
}