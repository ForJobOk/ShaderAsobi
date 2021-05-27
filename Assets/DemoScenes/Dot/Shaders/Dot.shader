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
            };

            float4 _Color1;
            float4 _Color2;

            //頂点シェーダー
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //3D空間座標→スクリーン座標変換
                o.uv = v.uv; //受け取ったUV座標をフラグメントシェーダーでも使う？
                return o;
            }

            //フラグメントシェーダー
            fixed4 frag(v2f i) : SV_Target
            {
                float direction = dot(i.uv,normalize(float2(1,0.5)));
                fixed4 col = lerp(_Color1,_Color2, direction);
                return col;
            }
            ENDCG
        }
    }
}