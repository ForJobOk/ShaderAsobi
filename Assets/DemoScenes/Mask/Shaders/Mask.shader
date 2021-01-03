Shader "Custom/Mask"
{
    //Inspectorに出すプロパティー
    Properties
    {
        //テクスチャー(オフセットの設定なし)
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        //Mask用テクスチャー
        [NoScaleOffset] _MaskTex("Mask Texture (RGB)", 2D) = "white" {}
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
                float2 uv1 : TEXCOORD0; //1番目のUV座標 たぶんテクスチャが複数枚あって別々に何かしたいときに助かるやつ
            };

            //フラグメントシェーダーへ渡すデータ
            struct v2f
            {
                float2 uv1 : TEXCOORD0; //テクスチャUV
                float4 vertex : SV_POSITION; //座標変換された後の頂点座標
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;

            //頂点シェーダー
            v2f vert(appdata  v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //3D空間座標→スクリーン座標変換
                o.uv1 = v.uv1;
                return o;
            }

            //フラグメントシェーダー
            fixed4 frag(v2f i) : SV_Target
            {
                //マスク用画像のピクセルの色を計算
                fixed4 mask = tex2D(_MaskTex, i.uv1);
                //引数の値が"0以下なら"描画しない　すなわち"Alphaが0.5以下なら"描画しない
                clip(mask.a - 0.5);
                //メインテクスチャーの色を取得
                fixed4 col = tex2D(_MainTex, i.uv1);
                //メイン画像とマスク画像のピクセルの計算結果を掛け合わせる
                return col * mask;
            }
            ENDCG
        }
    }
}