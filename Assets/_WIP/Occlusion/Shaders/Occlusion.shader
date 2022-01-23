Shader "Custom/Occlusion"
{
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase" "RenderType"="Opaque-1"
            }
            
            Blend Zero SrcColor

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #include "AutoLight.cginc"

            struct appdata
            {
                float3 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                LIGHTING_COORDS(0,1)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            float4 frag(v2f i) : COLOR
            {
                float attenuation = SHADOW_ATTENUATION(i);
                return float4(1,1,1,1) * attenuation;
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