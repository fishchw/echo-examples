<?xml version="1.0" encoding="utf-8"?>
<res class="ShaderProgram" class="ShaderProgram" path="Res://NormapMap/NormalMap.shader" Type="glsl" VertexShader="#version 450&#10;&#10;layout(binding = 0, std140) uniform UBO&#10;{&#10;    mat4 u_WorldMatrix;&#10;    mat4 u_ViewProjMatrix;&#10;} vs_ubo;&#10;&#10;layout(location = 0) in vec3 a_Position;&#10;layout(location = 0) out vec3 v_Position;&#10;layout(location = 1) out vec3 v_Normal;&#10;layout(location = 1) in vec3 a_Normal;&#10;layout(location = 4) out vec2 v_UV;&#10;layout(location = 4) in vec2 a_UV;&#10;&#10;void main()&#10;{&#10;    vec4 position = vs_ubo.u_WorldMatrix * vec4(a_Position, 1.0);&#10;    position = vs_ubo.u_ViewProjMatrix * position;&#10;    gl_Position = position;&#10;    v_Position = position.xyz;&#10;    v_Normal = normalize(vec3((vs_ubo.u_WorldMatrix * vec4(a_Normal, 0.0)).xyz));&#10;    v_UV = a_UV;&#10;}&#10;&#10;" FragmentShader="#version 450&#10;&#10;struct PBRInfo&#10;{&#10;    float NdotL;&#10;    float NdotV;&#10;    float NdotH;&#10;    float LdotH;&#10;    float VdotH;&#10;    float perceptualRoughness;&#10;    float metalness;&#10;    vec3 reflectance0;&#10;    vec3 reflectance90;&#10;    float alphaRoughness;&#10;    vec3 diffuseColor;&#10;    vec3 specularColor;&#10;};&#10;&#10;layout(binding = 0, std140) uniform UBO&#10;{&#10;    vec3 u_CameraPosition;&#10;} fs_ubo;&#10;&#10;layout(binding = 1) uniform sampler2D NormalMap;&#10;&#10;layout(location = 0) in vec3 v_Position;&#10;layout(location = 4) in vec2 v_UV;&#10;layout(location = 0) out vec4 o_FragColor;&#10;layout(location = 1) in vec3 v_Normal;&#10;&#10;vec3 _NormalMapFun(vec3 n)&#10;{&#10;    vec3 pos_dx = dFdx(v_Position);&#10;    vec3 pos_dy = dFdy(v_Position);&#10;    vec3 tex_dx = dFdx(vec3(v_UV, 0.0));&#10;    vec3 tex_dy = dFdy(vec3(v_UV, 0.0));&#10;    vec3 t = ((pos_dx * tex_dy.y) - (pos_dy * tex_dx.y)) / vec3((tex_dx.x * tex_dy.y) - (tex_dy.x * tex_dx.y));&#10;    vec3 ng = cross(pos_dx, pos_dy);&#10;    t = normalize(t - (ng * dot(ng, t)));&#10;    vec3 b = normalize(cross(ng, t));&#10;    mat3 tbn = mat3(vec3(t), vec3(b), vec3(ng));&#10;    return normalize(tbn * ((n * 2.0) - vec3(1.0)));&#10;}&#10;&#10;vec3 SRgbToLinear(vec3 srgbIn)&#10;{&#10;    return pow(srgbIn, vec3(2.2000000476837158203125));&#10;}&#10;&#10;vec3 specularReflection(PBRInfo pbrInputs)&#10;{&#10;    return pbrInputs.reflectance0 + ((pbrInputs.reflectance90 - pbrInputs.reflectance0) * pow(clamp(1.0 - pbrInputs.VdotH, 0.0, 1.0), 5.0));&#10;}&#10;&#10;float geometricOcclusion(PBRInfo pbrInputs)&#10;{&#10;    float NdotL = pbrInputs.NdotL;&#10;    float NdotV = pbrInputs.NdotV;&#10;    float r = pbrInputs.alphaRoughness;&#10;    float attenuationL = (2.0 * NdotL) / (NdotL + sqrt((r * r) + ((1.0 - (r * r)) * (NdotL * NdotL))));&#10;    float attenuationV = (2.0 * NdotV) / (NdotV + sqrt((r * r) + ((1.0 - (r * r)) * (NdotV * NdotV))));&#10;    return attenuationL * attenuationV;&#10;}&#10;&#10;float microfacetDistribution(PBRInfo pbrInputs)&#10;{&#10;    float roughnessSq = pbrInputs.alphaRoughness * pbrInputs.alphaRoughness;&#10;    float f = (((pbrInputs.NdotH * roughnessSq) - pbrInputs.NdotH) * pbrInputs.NdotH) + 1.0;&#10;    return roughnessSq / ((3.1415927410125732421875 * f) * f);&#10;}&#10;&#10;vec3 diffuse(PBRInfo pbrInputs)&#10;{&#10;    return pbrInputs.diffuseColor / vec3(3.1415927410125732421875);&#10;}&#10;&#10;vec3 PbrLighting(vec3 pixelPosition, vec3 baseColor, vec3 normal, float metallic, float perceptualRoughness, vec3 eyePosition)&#10;{&#10;    float alphaRoughness = perceptualRoughness * perceptualRoughness;&#10;    vec3 f0 = vec3(0.039999999105930328369140625);&#10;    vec3 diffuseColor = baseColor * (vec3(1.0) - f0);&#10;    diffuseColor *= (1.0 - metallic);&#10;    vec3 specularColor = mix(f0, baseColor, vec3(metallic));&#10;    float reflectance = max(max(specularColor.x, specularColor.y), specularColor.z);&#10;    float reflectance90 = clamp(reflectance * 25.0, 0.0, 1.0);&#10;    vec3 specularEnvironmentR0 = specularColor;&#10;    vec3 specularEnvironmentR90 = vec3(1.0) * reflectance90;&#10;    vec3 n = normal;&#10;    vec3 v = normalize(eyePosition - pixelPosition);&#10;    float NdotV = abs(dot(n, v)) + 0.001000000047497451305389404296875;&#10;    vec3 _lightDir = vec3(0.57735025882720947265625);&#10;    vec3 param = vec3(1.2000000476837158203125);&#10;    vec3 _lightColor = SRgbToLinear(param);&#10;    vec3 l = normalize(_lightDir);&#10;    vec3 h = normalize(l + v);&#10;    vec3 reflection = -normalize(reflect(v, n));&#10;    float NdotL = clamp(dot(n, l), 0.001000000047497451305389404296875, 1.0);&#10;    float NdotH = clamp(dot(n, h), 0.0, 1.0);&#10;    float LdotH = clamp(dot(l, h), 0.0, 1.0);&#10;    float VdotH = clamp(dot(v, h), 0.0, 1.0);&#10;    PBRInfo pbrInputs = PBRInfo(NdotL, NdotV, NdotH, LdotH, VdotH, perceptualRoughness, metallic, specularEnvironmentR0, specularEnvironmentR90, alphaRoughness, diffuseColor, specularColor);&#10;    PBRInfo param_1 = pbrInputs;&#10;    vec3 F = specularReflection(param_1);&#10;    PBRInfo param_2 = pbrInputs;&#10;    float G = geometricOcclusion(param_2);&#10;    PBRInfo param_3 = pbrInputs;&#10;    float D = microfacetDistribution(param_3);&#10;    PBRInfo param_4 = pbrInputs;&#10;    vec3 diffuseContrib = (vec3(1.0) - F) * diffuse(param_4);&#10;    vec3 specContrib = ((F * G) * D) / vec3((4.0 * NdotL) * NdotV);&#10;    vec3 color = (_lightColor * NdotL) * (diffuseContrib + specContrib);&#10;    vec3 param_5 = vec3(0.300000011920928955078125);&#10;    vec3 _environmentLightColor = SRgbToLinear(param_5);&#10;    color += (baseColor * _environmentLightColor);&#10;    return color;&#10;}&#10;&#10;vec3 LinearToSRgb(vec3 linearIn)&#10;{&#10;    return pow(linearIn, vec3(0.4545454680919647216796875));&#10;}&#10;&#10;void main()&#10;{&#10;    vec4 NormalMap_Color = texture(NormalMap, v_UV);&#10;    vec3 param = NormalMap_Color.xyz;&#10;    vec3 _445 = _NormalMapFun(param);&#10;    NormalMap_Color = vec4(_445.x, _445.y, _445.z, NormalMap_Color.w);&#10;    vec4 Color_25_Value = vec4(0.267358005046844482421875, 0.680020987987518310546875, 0.4313400089740753173828125, 1.0);&#10;    vec3 _BaseColor = Color_25_Value.xyz;&#10;    vec3 _Normal = NormalMap_Color.xyz;&#10;    float _Opacity = 1.0;&#10;    float _Metalic = 0.20000000298023223876953125;&#10;    float _PerceptualRoughness = 0.5;&#10;    vec3 param_1 = v_Position;&#10;    vec3 param_2 = _BaseColor;&#10;    vec3 param_3 = _Normal;&#10;    float param_4 = _Metalic;&#10;    float param_5 = _PerceptualRoughness;&#10;    vec3 param_6 = fs_ubo.u_CameraPosition;&#10;    _BaseColor = PbrLighting(param_1, param_2, param_3, param_4, param_5, param_6);&#10;    vec3 param_7 = _BaseColor;&#10;    o_FragColor = vec4(LinearToSRgb(param_7), _Opacity);&#10;}&#10;&#10;" Graph="{&#10;    &quot;connections&quot;: [&#10;        {&#10;            &quot;in_id&quot;: &quot;{b3b4dea8-4b11-4691-b8cc-41dd42e1aad7}&quot;,&#10;            &quot;in_index&quot;: 2,&#10;            &quot;out_id&quot;: &quot;{80b76713-6bc3-4ecb-9e63-0c15f5127d42}&quot;,&#10;            &quot;out_index&quot;: 0&#10;        },&#10;        {&#10;            &quot;in_id&quot;: &quot;{b3b4dea8-4b11-4691-b8cc-41dd42e1aad7}&quot;,&#10;            &quot;in_index&quot;: 0,&#10;            &quot;out_id&quot;: &quot;{f9eb1f17-3d85-4f71-b193-e688a7ed51dc}&quot;,&#10;            &quot;out_index&quot;: 0&#10;        }&#10;    ],&#10;    &quot;nodes&quot;: [&#10;        {&#10;            &quot;id&quot;: &quot;{b3b4dea8-4b11-4691-b8cc-41dd42e1aad7}&quot;,&#10;            &quot;model&quot;: {&#10;                &quot;name&quot;: &quot;ShaderTemplate&quot;&#10;            },&#10;            &quot;position&quot;: {&#10;                &quot;x&quot;: 0,&#10;                &quot;y&quot;: 304&#10;            }&#10;        },&#10;        {&#10;            &quot;id&quot;: &quot;{80b76713-6bc3-4ecb-9e63-0c15f5127d42}&quot;,&#10;            &quot;model&quot;: {&#10;                &quot;isAtla&quot;: &quot;false&quot;,&#10;                &quot;isParameter&quot;: &quot;true&quot;,&#10;                &quot;name&quot;: &quot;Texture&quot;,&#10;                &quot;texture&quot;: &quot;&quot;,&#10;                &quot;type&quot;: &quot;NormalMap&quot;,&#10;                &quot;variableName&quot;: &quot;NormalMap&quot;&#10;            },&#10;            &quot;position&quot;: {&#10;                &quot;x&quot;: -456,&#10;                &quot;y&quot;: 427&#10;            }&#10;        },&#10;        {&#10;            &quot;id&quot;: &quot;{f9eb1f17-3d85-4f71-b193-e688a7ed51dc}&quot;,&#10;            &quot;model&quot;: {&#10;                &quot;color&quot;: &quot;0.54902 0.839216 0.682353 1 &quot;,&#10;                &quot;isParameter&quot;: &quot;false&quot;,&#10;                &quot;name&quot;: &quot;Color&quot;,&#10;                &quot;variableName&quot;: &quot;Color_25&quot;&#10;            },&#10;            &quot;position&quot;: {&#10;                &quot;x&quot;: -441,&#10;                &quot;y&quot;: 203&#10;            }&#10;        }&#10;    ]&#10;}&#10;" CullMode="CULL_BACK" BlendMode="Opaque" />
