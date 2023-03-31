shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;

void fragment() {
    DEPTH = 1.0;
}