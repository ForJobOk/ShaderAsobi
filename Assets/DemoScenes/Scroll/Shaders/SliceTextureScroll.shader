Shader "Custom/SliceTextureScroll"
{
    Properties
    {
        //スクロールさせるテクスチャ
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        //色
        _Color("MainColor",Color) = (0,0,0,0)
        //スライスされる間隔
        _SliceSpace("SliceSpace",Range(0,30)) = 15
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType"="Opaque"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            //変数の宣言　Propertiesで定義した名前と一致させる
            sampler2D _MainTex;
            half4 _Color;
            half _SliceSpace;

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                //描画しようとしているピクセル(ローカル座標)
                o.localPos = v.vertex.xyz;
                o.uv = v.uv + _Time;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                //ピクセルの色を計算
                fixed4 col = tex2D(_MainTex, i.uv);
                //各ピクセルのローカル座標(Y軸)それぞれに15をかけてfrac関数で少数だけ取り出す
                //そこから-0.5してclip関数で0を下回ったら描画しない
                clip(frac(i.localPos.y * _SliceSpace) - 0.5);
                //計算したピクセルとプロパティで設定した色を乗算する
                return half4(col * _Color);
            }
            ENDCG
        }
    }
}