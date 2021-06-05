Shader "Custom/SwitchTexture"
{
    Properties
    {
        _BackTexture ("Back Texture", 2D) = "white" {}
        _FrontTexture ("Front Texture", 2D) = "white" {}
        [Toggle] _RenderSwitch("RenderSwitch", Float) = 0
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
            float _RenderSwitch;
            
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
                float4 finalCol = lerp(backCol,frontCol,_RenderSwitch);               
                return finalCol;
            }
            ENDCG
        }
    }
}