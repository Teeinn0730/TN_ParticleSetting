﻿Shader "TN/Particle Settings"
{
    Properties{
        [Header(Properties)]
        _X_Speed ("X_Speed", Float ) = 0
        _Y_Speed ("Y_Speed", Float ) = 0
        [MaterialToggle] _SceneUV ("SceneUV", Float ) = 0
        _MainTex ("MainTex", 2D) = "white" {}
        [HDR]_MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        [MaterialToggle] _Fresnel ("Fresnel", Float ) = 0
        _Fresnel_Range ("Fresnel_Range", Range(0, 5)) = 1
        _Fresnel_Intensity ("Fresnel_Intensity", Range(0, 5)) = 1
        [HDR]_Fresnel_Color ("Fresnel_Color", Color) = (0.5,0.5,0.5,1)
/////Blend Settings:
        [Header(Blend Settings)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SourceBlend ("SrcBlend",Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _DestBlend ("DestBlend",Float) = 0
        [Enum(Off,0,Front,1,Back,2)] _Cull("CullMask",Float) = 0
        [Enum(Off,0,On,1)] _ZWrite("Zwrite",Float) = 0
        [Enum(Less,0, Greater,1, LEqual,2, GEqual,3, Equal,4, NotEqual,5, Always,6)] _ZTest ("ZTest", Float) = 2
/////interupte uv:
        [Header(Interupte UV)]
        [MaterialToggle] _InterupteToggle ("InterupteToggle", Float ) = 0
        _InterupteTex("interupteTex",2D) = "white"{}
        _InterupteValue("interupteValue",Range(0,1)) = 0
/////Desaturate:
        [Header(Desaturate)]
        [MaterialToggle] _desaturate ("Desaturate", Float ) = 0
        [HDR]_desaturateColor("DesaturateColor",Color)=(1,1,1,1)
/////ReColor_Gradient:
        [Header(ReColor_Gradient)]
        [MaterialToggle] _colorGradient("ColorGradient(need to use Desaturate)",Float) = 0
        _GradientValue("GradientValue",Range(0,1)) = 0.5
        [HDR] _color1("BrightColor",Color) = (1,1,1,1)
        [HDR] _color2("DarkColor",Color) = (0.5,0.5,0.5,1)
/////UVTile:
        [Header(Sequence For Trail)]
        [MaterialToggle] _UseUVtile("UseUVTile",Float) = 0
        _UVtileXY ("UVTile",Vector) = (0,0,0,0)
        _UVtileSpd ("UVTileSpd" , Float) = 0
/////UVRotator:
        [Header(UV Rotator)]
        [MaterialToggle] _UseUVRotator ("UseUVRotator", Float) = 0
        _UVRotator_Angle ("Rotator" , Float) = 0
/////Facing:
        [Header(FaceColor)]
        [MaterialToggle] _UseFacing ("UseFacing?",Float) = 0
        [HDR] _BackColor ("BackColor" ,Color) = (0.5,0.5,0.5,1)
/////Alpha Texture:
        [Header(Alpha Tex(Need UV0 Custom.z))]
        [MaterialToggle] _UseAlphaTex ("UseAlphaTex?",Float) = 0
        _AlphaTexture("AlphaTexture",2D)="white"{}
        _AlphaTexture_Step("AlphaTexture_Step",Range(0,0.5)) = 0
/////Decal Shader:
        [Header(Decal(Need open SceneUV and Depth Cam))]
        [MaterialToggle] _UseDecal ("UseDecal?" , Float) = 0
        _NormalClipThreshold("NormalClip",Range(0,0.3)) = 0.1
/////Stencil Settings:
        [Header(Stencil Settings)]
        _Ref ("Ref",Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _Comp ("Comparison",Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _Pass ("Pass ",Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _Fail ("Fail ",Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _ZFail ("ZFail ",Float) = 0
        
    }
    SubShader{
        Tags{
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        
        Stencil {
             Ref [_Ref]          //0-255
             Comp [_Comp]     //default:always
             Pass [_Pass]   //default:keep
             Fail [_Fail]      //default:keep
             ZFail [_ZFail]     //default:keep
        }
        Pass{
            Tags{
                "LightMode"="ForwardBase"
            }
            Blend [_SourceBlend] [_DestBlend]
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
            #pragma exclude_renderers gles
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_instancing
            #pragma instancing_options procedural:vertInstancingSetup
            #include "UnityCG.cginc"
            #include "UnityStandardParticleInstancing.cginc"

            struct VertexInput{
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 vertexColor : COLOR;
                float4 uv : TEXCOORD0;
            };
            struct VertexOutput{
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 projPos : TEXCOORD2;
                float4 vertexColor : COLOR;
                float4 uv : TEXCOORD3;
                float3 ray : TEXCOORD4;
                //float3 yDir : TEXCOORD5;
            };

            sampler2D _MainTex , _InterupteTex , _AlphaTexture , _CameraDepthTexture , _CameraGBufferTexture2 ;
            float4 _InterupteTex_ST ,  _MainTex_ST , _AlphaTexture_ST ;
            float _X_Speed , _Y_Speed , _Fresnel_Range , _Fresnel_Intensity , _Fresnel , _SceneUV , _InterupteValue , _InterupteToggle , _desaturate , _colorGradient , _GradientValue , _UseUVtile , _UVtileSpd , _UseFacing , _UseUVRotator , _UVRotator_Angle , _UseAlphaTex , _AlphaTexture_Step , _NormalClipThreshold , _UseDecal , _UseVertexExtrude ;
            float4 _MainColor , _Fresnel_Color , _desaturateColor , _color1 , _color2 , _UVtileXY , _BackColor;

/////   InverseLerp func :
            float InverseLerp(float a , float b , float c){ 
                return saturate((c-a)/(b-a));
			}
/////   Vert:
            VertexOutput vert (VertexInput v ){
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                o.normal = UnityObjectToWorldNormal(v.normal); 
                o.vertexColor = v.vertexColor;
                o.uv = v.uv ;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld,v.vertex);
                o.ray = 0;
                //o.yDir = 0;
                if(_SceneUV){
                    o.projPos = ComputeScreenPos(o.pos);
                    COMPUTE_EYEDEPTH(o.projPos.z);
                }
                else{
                     o.projPos = v.uv;
                }
                if(_UseDecal){
                    o.ray = UnityObjectToViewPos(v.vertex) * float3(1,1,-1);
                    //o.yDir = mul((float3x3)unity_ObjectToWorld,float3(0,1,0));
				} 
                return o;
            }

            float4 frag(VertexOutput o, float facing : VFACE) : SV_Target{
                o.normal = normalize(o.normal);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz-o.posWorld.xyz);
/////////Facing:
                float3 FaceColor = 1;
                if(_UseFacing){ FaceColor = (facing >= 0 ? _BackColor : 1); }
                //float isFrontFace = ( facing >= 0 ? 1 : 0 );
                //float faceSign = ( facing >= 0 ? 1 : -1 );
/////////UVTile:
                float UVTile_TimeSpeed , UVTile_X , UVTile_Y= 0 ; float2 UVTile =0;
                if(_UseUVtile){
                    UVTile_TimeSpeed = trunc(_Time.g *  _UVtileSpd);
                    UVTile = float2 (1,1) / float2 (_UVtileXY.x,_UVtileXY.y);
                    UVTile_X = floor(UVTile_TimeSpeed * UVTile.x);
                    UVTile_Y = UVTile_TimeSpeed - _UVtileXY.x * UVTile_X;
                }
/////////SceneUV :
                float2 SceneUV = o.projPos.xy / o.projPos.w; 
                if(_InterupteToggle){
                    float2 InterupteUV = o.projPos.xy / o.projPos.w;
                    InterupteUV += float2(_X_Speed,_Y_Speed)*_Time.g;
                    float4 InterupteTex = tex2D(_InterupteTex,TRANSFORM_TEX(InterupteUV,_InterupteTex));
                    SceneUV = lerp( SceneUV , InterupteTex.rg , _InterupteValue );
                }
                else{
                    SceneUV += float2(_X_Speed,_Y_Speed)*_Time.g;
                }
                if(_UseUVtile){
                    SceneUV = (SceneUV+float2(UVTile_Y,UVTile_X)) * UVTile;
                }
/////////UV Rotator:
                float UVRotator_cos , UVRotator_sin = 0;
                if(_UseUVRotator){
                    UVRotator_cos = cos(_UVRotator_Angle * _Time.g);
                    UVRotator_sin = sin(_UVRotator_Angle * _Time.g);
                    float2 Pivot = float2(0.5,0.5);
                    SceneUV = mul( SceneUV - Pivot , float2x2( UVRotator_cos , -UVRotator_sin , UVRotator_sin , UVRotator_cos))+ Pivot;
                }
/////////Fresnel :
                float3 fresnel = pow(1-max(0,(dot(viewDir,o.normal))),_Fresnel_Range);
                float3 fresnel_Color = fresnel * _Fresnel_Color *_Fresnel_Intensity;
/////////Decal: 
                if(_UseDecal){
                    vertInstancingSetup();
                    float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture , SceneUV);
				    float viewDepth = Linear01Depth(depth) * _ProjectionParams.z;
                    float3 viewPos = o.ray * viewDepth / o.ray.z ; 
                    float4 worldPos = mul (unity_CameraToWorld , float4(viewPos,1 ) ) ;
                    float3 objectPos = mul (unity_WorldToObject , worldPos);
                    //return float4(objectPos.xyz,1);
                    //objectPos = UnityObjectToWorldPos(float4(objectPos,0));
                    clip(float3(0.5,0.5,0.5) - abs(objectPos));
                    //float3 worldNormal = tex2D(_CameraGBufferTexture2,SceneUV).rgb*2-1;
                    //float3 yDir = normalize(o.yDir) ;
                    //clip(dot( yDir , worldNormal ) - _NormalClipThreshold );
                    SceneUV = objectPos.xz + 0.5;
                }
/////////FinalColor :
                float4 MainTex = tex2D(_MainTex,TRANSFORM_TEX(SceneUV,_MainTex));
/////////Desaturate:
                if(_desaturate){
                    MainTex.rgb = dot(MainTex.rgb,float3(0.3,0.59,0.11));
                    if(_colorGradient){
                        float3 TexColor_Smoothstep = smoothstep(MainTex.rgb+0.4 , MainTex.rgb , _GradientValue);
                        float3 BrightColor = MainTex.rgb * TexColor_Smoothstep * _color1 ;
                        float3 DarkColor = MainTex.rgb * (1-TexColor_Smoothstep) * _color2;
                        MainTex.rgb = BrightColor+DarkColor;
                    }
                    else{
                       MainTex.rgb = MainTex.rgb*_desaturateColor.rgb;
                    }
                }
/////////Alpha:
                float4 AlphaTexture = 1;
                float Alpha =  MainTex.a*o.vertexColor.a ; 
                if(_UseAlphaTex){
                    AlphaTexture = tex2D(_AlphaTexture,TRANSFORM_TEX(o.uv,_AlphaTexture));
                    Alpha *= saturate(InverseLerp( _AlphaTexture_Step , 1-_AlphaTexture_Step , AlphaTexture.r)+o.uv.z); 
				}
/////////FinalColor:
                float3 MainTex2 = MainTex.rgb*_MainColor.rgb*o.vertexColor.rgb+ fresnel_Color;
                if(_Fresnel){
                    return float4(MainTex2*FaceColor,Alpha);
                }
                else{
                     return float4(MainTex.rgb*_MainColor.rgb*o.vertexColor.rgb*FaceColor ,  Alpha);
                }
            }
            ENDCG
        }
    }
}
