Shader "Custom/2DWave"
{
    Properties
    {
        //メインテクスチャー
        _MainTex ("Texture", 2D) = "white" {}
        //グラデーションカラー
        _TopColor("TopColor",Color) = (0,0,0,0)
        _UnderColor("UnderColor",Color) = (0,0,0,0)
        //色の境界の位置
        _ColorBorder("ColorBorder",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Tranparent"
        }
        
        //不当明度を利用するときに必要 文字通り、1 - フラグメントシェーダーのAlpha値　という意味
        Blend SrcAlpha OneMinusSrcAlpha
        //両面描画
        Cull Off

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

            sampler2D _MainTex;
            float4 _UnderColor;
            float4 _TopColor;
            float _ColorBorder;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 base_color = tex2D(_MainTex, i.uv);
                float4 main_color = lerp(_UnderColor, _TopColor, i.uv.y * _ColorBorder);
                float4 final_color = base_color * main_color;

                return final_color;
            }
            ENDCG
        }
    }
}