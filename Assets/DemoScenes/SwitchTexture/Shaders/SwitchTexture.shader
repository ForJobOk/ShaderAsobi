Shader "Custom/SwitchTexture"
{
    Properties
    {
        _FrontTexture ("Front Texture", 2D) = "white" {}
        _BackTexture ("Back Texture", 2D) = "white" {}
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType"="Opaque"
            }
            
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D  _FrontTexture;
            sampler2D  _BackTexture;

            //C#から受け取る値
            float _Threshold;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float4 frontCol = tex2D(_FrontTexture,i.uv);
                float4 backCol = tex2D(_BackTexture,i.uv);
                float interpolation = 1 - step(_Threshold,0);
                float4 finalCol = lerp(backCol,frontCol,interpolation);               
                return finalCol;
            }
            ENDCG
        }
    }
}