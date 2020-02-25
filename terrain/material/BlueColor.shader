<?xml version="1.0" encoding="utf-8"?>
<res name="ShaderProgram" class="ShaderProgram" name="ShaderProgram" class="ShaderProgram" path="Res://material/BlueColor.shader" Type="glsl" VertexShader="#version 450&#10;&#10;#define ENABLE_VERTEX_UV0&#10;#define ENABLE_VERTEX_NORMAL&#10;#define ENABLE_BASE_COLOR&#10;#define ENABLE_LIGHTING_CALCULATION&#10;#define ENABLE_OPACITY&#10;&#10;&#10;// uniforms&#10;layout(binding = 0) uniform UBO&#10;{&#10;    mat4 u_WorldMatrix;&#10;    mat4 u_WorldViewProjMatrix;&#10;} vs_ubo;&#10;&#10;// inputs&#10;layout(location = 0) in vec3 a_Position;&#10;&#10;#ifdef ENABLE_VERTEX_POSITION&#10;layout(location = 0) out vec3 v_Position;&#10;#endif&#10;&#10;#ifdef ENABLE_VERTEX_NORMAL&#10;layout(location = 1) in vec3 a_Normal;&#10;layout(location = 1) out vec3 v_Normal;&#10;#endif&#10;&#10;#ifdef ENABLE_VERTEX_COLOR&#10;layout(location = 2) in vec4 a_Color;&#10;layout(location = 2) out vec4 v_Color;&#10;#endif&#10;&#10;#ifdef ENABLE_VERTEX_UV0&#10;layout(location = 3) in vec2 a_UV;&#10;layout(location = 3) out vec2 v_UV;&#10;#endif&#10;&#10;void main(void)&#10;{&#10;    vec4 position = vs_ubo.u_WorldViewProjMatrix * vec4(a_Position, 1.0);&#10;    gl_Position = position;&#10;&#10;#ifdef ENABLE_VERTEX_POSITION&#10;    vec4 pos   = vs_ubo.u_WorldMatrix * vec4(a_Position, 1.0);&#10;    v_Position = vec3(pos.xyz) / pos.w;&#10;#endif&#10;&#10;#ifdef ENABLE_VERTEX_NORMAL&#10;    v_Normal = normalize(vec3(vs_ubo.u_WorldMatrix * vec4(a_Normal.xyz, 0.0)));&#10;#endif&#10;&#10;#ifdef ENABLE_VERTEX_COLOR&#10;    v_Color = a_Color;&#10;#endif&#10;&#10;#ifdef ENABLE_VERTEX_UV0    &#10;    v_UV = a_UV;&#10;#endif&#10;}&#10;" FragmentShader="#version 450&#10;&#10;#define ENABLE_VERTEX_UV0&#10;#define ENABLE_VERTEX_NORMAL&#10;#define ENABLE_BASE_COLOR&#10;#define ENABLE_LIGHTING_CALCULATION&#10;#define ENABLE_OPACITY&#10;&#10;&#10;precision mediump float;&#10;&#10;// uniforms&#10;&#10;&#10;// texture uniforms&#10;layout(binding = 1) uniform sampler2D Texture_7;&#10;&#10;&#10;// inputs&#10;#ifdef ENABLE_VERTEX_POSITION&#10;layout(location = 0) in vec3  v_Position;&#10;#endif&#10;&#10;#ifdef ENABLE_VERTEX_NORMAL&#10;layout(location = 1) in vec3 v_Normal;&#10;#endif&#10;&#10;#ifdef ENABLE_VERTEX_COLOR&#10;layout(location = 2) in vec4  v_Color;&#10;#endif&#10;&#10;#ifdef ENABLE_VERTEX_UV0&#10;layout(location = 3) in vec2  v_UV;&#10;#endif&#10;&#10;// outputs&#10;layout(location = 0) out vec4 o_FragColor;&#10;&#10;void main(void)&#10;{&#10;    float Float_5 = 0.250000;&#10;    vec4 Texture_7_Color = texture( Texture_7, v_UV);&#10;    vec3 __BaseColor = Texture_7_Color.rgb;&#10;    float __Opacity = Float_5;&#10;&#10;&#10;#ifndef ENABLE_BASE_COLOR &#10;    vec3 __BaseColor = vec3(0.75);&#10;#endif&#10;&#10;#ifndef ENABLE_OPACITY&#10;    float __Opacity = 1.0;&#10;#endif&#10;&#10;#ifdef ENABLE_LIGHTING_CALCULATION&#10;    vec3 _lightDir = normalize(vec3(1.0, 1.0, 1.0));&#10;    vec3 _lightColor = vec3(0.8, 0.8, 0.8);&#10;    __BaseColor = max(dot(v_Normal, _lightDir), 0.0) * _lightColor * __BaseColor;&#10;#endif&#10;&#10;    o_FragColor = vec4(__BaseColor.rgb, __Opacity);&#10;}&#10;" Graph="{&#10;    &quot;connections&quot;: [&#10;        {&#10;            &quot;in_id&quot;: &quot;{d84313df-7c86-4ae3-a8ba-043876f70dae}&quot;,&#10;            &quot;in_index&quot;: 1,&#10;            &quot;out_id&quot;: &quot;{8e987de1-16cf-492d-818a-054bc0b78f43}&quot;,&#10;            &quot;out_index&quot;: 0&#10;        },&#10;        {&#10;            &quot;in_id&quot;: &quot;{d84313df-7c86-4ae3-a8ba-043876f70dae}&quot;,&#10;            &quot;in_index&quot;: 0,&#10;            &quot;out_id&quot;: &quot;{0a3c03cf-34cd-4a36-9891-da8db27e6908}&quot;,&#10;            &quot;out_index&quot;: 0&#10;        },&#10;        {&#10;            &quot;in_id&quot;: &quot;{d84313df-7c86-4ae3-a8ba-043876f70dae}&quot;,&#10;            &quot;in_index&quot;: 4,&#10;            &quot;out_id&quot;: &quot;{f8fbd75d-ccee-4698-a99a-a124136281fd}&quot;,&#10;            &quot;out_index&quot;: 0&#10;        }&#10;    ],&#10;    &quot;nodes&quot;: [&#10;        {&#10;            &quot;id&quot;: &quot;{f8fbd75d-ccee-4698-a99a-a124136281fd}&quot;,&#10;            &quot;model&quot;: {&#10;                &quot;name&quot;: &quot;Float&quot;,&#10;                &quot;number&quot;: &quot;0.25&quot;&#10;            },&#10;            &quot;position&quot;: {&#10;                &quot;x&quot;: -102,&#10;                &quot;y&quot;: 376&#10;            }&#10;        },&#10;        {&#10;            &quot;id&quot;: &quot;{0a3c03cf-34cd-4a36-9891-da8db27e6908}&quot;,&#10;            &quot;model&quot;: {&#10;                &quot;name&quot;: &quot;Texture&quot;,&#10;                &quot;texture&quot;: &quot;Res://icon.png&quot;&#10;            },&#10;            &quot;position&quot;: {&#10;                &quot;x&quot;: -122,&#10;                &quot;y&quot;: 54&#10;            }&#10;        },&#10;        {&#10;            &quot;id&quot;: &quot;{d84313df-7c86-4ae3-a8ba-043876f70dae}&quot;,&#10;            &quot;model&quot;: {&#10;                &quot;name&quot;: &quot;ShaderTemplate&quot;&#10;            },&#10;            &quot;position&quot;: {&#10;                &quot;x&quot;: 310,&#10;                &quot;y&quot;: 168&#10;            }&#10;        },&#10;        {&#10;            &quot;id&quot;: &quot;{8e987de1-16cf-492d-818a-054bc0b78f43}&quot;,&#10;            &quot;model&quot;: {&#10;                &quot;name&quot;: &quot;Input&quot;,&#10;                &quot;option&quot;: &quot;normal&quot;&#10;            },&#10;            &quot;position&quot;: {&#10;                &quot;x&quot;: -101,&#10;                &quot;y&quot;: 276&#10;            }&#10;        }&#10;    ]&#10;}&#10;" CullMode="CULL_BACK" BlendMode="Opaque" />
