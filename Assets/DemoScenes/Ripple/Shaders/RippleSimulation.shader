Shader "Custom/RippleSimulation"
{
    Properties
    {
        _CustomRendererTex("Custom Renderer Texture", 2D) = "gray" {}
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _CustomRendererTex;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //カスタムレンダーテクスチャーのピクセル情報を使用
                return tex2D(_CustomRendererTex, i.uv);
            }
            ENDCG
        }
    }
}