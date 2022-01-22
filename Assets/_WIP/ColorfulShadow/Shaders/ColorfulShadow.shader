Shader "Custom/ColorfulShadow"
{

    Properties
    {
         _Color("MainColor",Color) = (0,0,0,1)
        _ShadowTex("ShadowTexture", 2D) = "white" {}
        _MainTex("MainTexture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase" "RenderType"="Opaque"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            sampler2D _ShadowTex;
            float4 _ShadowTex_ST;
           float4 _Color;

            struct appdata
            {
                float3 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 pos : SV_POSITION;
                SHADOW_COORDS(2)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW(o);
                o.uv = float2(v.uv.xy * _ShadowTex_ST.xy + _ShadowTex_ST.zw);
                o.uv2 = v.uv;
                return o;
            }

            float4 frag(v2f i) : COLOR
            {
                float attenuation = SHADOW_ATTENUATION(i);
                float4 shadowColor = tex2D(_ShadowTex,i.uv) *_Color;
                float4 mainColor = tex2D(_MainTex,i.uv2);
                return lerp(shadowColor,mainColor,attenuation);
            }
            ENDCG
        }
        
        //影を落とす処理を行うPass
        Pass
        {
            Tags
            {
                "LightMode"="ShadowCaster"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}