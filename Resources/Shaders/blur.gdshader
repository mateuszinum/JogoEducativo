shader_type canvas_item;

// Esta é a linha que resolve o erro. Ela "puxa" a imagem da tela para o shader.
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Controle de intensidade no Inspetor (0.0 a 5.0)
uniform float lod : hint_range(0.0, 5.0) = 0.0;

void fragment() {
    // Agora o SCREEN_TEXTURE funciona corretamente aqui
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
    COLOR = color;
}