Shader "Custom/Dot"
{
    Properties
    {
        _Color1("Color 1",Color) = (0,0,0,0)
        _Color2("Color 2",Color) = (1,1,1,1)
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            //頂点シェーダーに渡ってくる頂点データ
            struct appdata
            {
                //セミコロン以降の大文字はセマンティクスと呼ばれる　
                //この変数は　○○を受け取ります　みたいなやつらしい
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0; //1番目のUV座標　という意味らしい　なるほどわからん
            };

            //フラグメントシェーダーへ渡すデータ
            struct v2f
            {
                float2 uv : TEXCOORD0; //テクスチャUV
                float4 vertex : SV_POSITION; //座標変換された後の頂点座標
                float3 worldPos : WORLD_POS;
            };

            float4 _Color1;
            float4 _Color2;

            //頂点シェーダー
            v2f vert(appdata v)
            {
                v2f o;
                //unity_ObjectToWorld × 頂点座標(v.vertex) = 描画しようとしてるピクセルのワールド座標　らしい
                //mulは行列の掛け算をやってくれる関数
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityObjectToClipPos(v.vertex); //3D空間座標→スクリーン座標変換
                o.uv = v.uv; //受け取ったUV座標をフラグメントシェーダーでも使う？
                return o;
            }

            //フラグメントシェーダー
            fixed4 frag(v2f i) : SV_Target
            {
                float interpolation = dot(normalize(i.worldPos),normalize(float2(1.0f,1.0f)));
                //float interpolation = dot(i.worldPos,normalize(float2(1.0f,1.0f)));
                fixed4 col = lerp(_Color1,_Color2, interpolation);
                return col;
            }
            ENDCG
        }
    }
}