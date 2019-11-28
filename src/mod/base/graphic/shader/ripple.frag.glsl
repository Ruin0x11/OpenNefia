extern number time;
extern Image background;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    float h = Texel(texture, texture_coords).x;
    float sh = 1.35 - h*2.;
    vec3 c =
       vec3(exp(pow(sh-.75,2.)*-10.),
            exp(pow(sh-.50,2.)*-20.),
            exp(pow(sh-.25,2.)*-10.));
    return vec4(c,1.);
    // vec3 e = vec3(vec2(1.)/resolution.xy,0.);
    // float p10 = Texel(texture, q-e.zy).x;
    // float p01 = Texel(texture, q-e.xz).x;
    // float p21 = Texel(texture, q+e.xz).x;
    // float p12 = Texel(texture, q+e.zy).x;

    // vec3 grad = normalize(vec3(p21 - p01, p12 - p10, 1.));
    // vec4 c = Texel(background, texture_coords.xy*2./resolution.xy + grad.xy*.35);
    // vec3 light = normalize(vec3(.2,-.5,.7));
    // float diffuse = dot(grad,light);
    // float spec = pow(max(0.,-reflect(light,grad).z),32.);
    // return mix(c,vec4(.7,.8,1.,1.),.25)*max(diffuse,0.) + spec;
}
