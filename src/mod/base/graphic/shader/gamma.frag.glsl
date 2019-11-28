ivec3 bitsPerChannel = ivec3(5, 5, 5);
float gamma = 1.02;

vec3 checker(vec2 coord, vec3 color)
{
    float intensity = float(mod(coord.x, 2.) == mod(coord.y, 2.));
    return intensity * color;
}

vec3 shade(vec2 uv, vec3 color)
{
    float intensity = uv.x;
    return intensity * color;
}

vec3 quantized(vec3 color, ivec3 bits)
{
    vec3 range = pow(vec3(2.), vec3(bits));
    return floor(color * range) / range;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = texture_coords.xy;
    vec3 result = Texel(texture, uv).xyz;

    float halfLuminosity = 0.5;

    result = quantized(result, bitsPerChannel);
    result = pow(result, vec3(1./gamma));

    return vec4(result, 1.);
}
