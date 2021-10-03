Shader "Custom/Firework"
{
    Properties
    {
        //メインテクスチャー
        _MainTex ("Texture", 2D) = "white" {}
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
                float4 uv : TEXCOORD0;
                //COLORを受け取る変数color
                float4 color : COLOR;
                //TEXCOORD1を受け取る変数alpha
                float alpha : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            sampler2D _MainTex;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                o.color.a = v.alpha;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //テクスチャーのサンプリング
                fixed4 tex_color = tex2D(_MainTex, i.uv);
                //引数の値が"0以下なら"描画しない　すなわち"Alphaが0.5以下なら"描画しない
                clip(tex_color.a - 0.5);
                float4 color = float4(tex_color * i.color.xyz,i.color.w);
                return color;
            }
            ENDCG
        }
    }
}