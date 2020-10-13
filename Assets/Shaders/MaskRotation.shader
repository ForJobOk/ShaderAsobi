Shader "Custom/MaskRotation"
{
    //Inspectorに出すプロパティー
    Properties
    {
        //テクスチャー(オフセットの設定なし)
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        //Mask用テクスチャー
        [NoScaleOffset] _MaskTex("Mask Texture (RGB)", 2D) = "white" {}
        //回転の速度
        _RotateSpeed ("Rotate Speed", float) = 1.0
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
                float2 uv1 : TEXCOORD0; //1番目のUV座標　という意味らしい たぶんテクスチャが複数枚あるときに助かるやつ
                float2 uv2 : TEXCOORD1; //2番目のUV座標　という意味らしい 
            };

            //フラグメントシェーダーへ渡すデータ
            struct v2f
            {
                float2 uv1 : TEXCOORD0; //テクスチャUV
                float2 uv2 : TEXCOORD1; //テクスチャUV
                float4 vertex : SV_POSITION; //座標変換された後の頂点座標
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            fixed _RotateSpeed;

            //頂点シェーダー
            v2f vert(appdata  v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //3D空間座標→スクリーン座標変換
                o.uv1 = v.uv1;
                o.uv2 = v.uv2;
                return o;
            }

            //フラグメントシェーダー
            fixed4 frag(v2f i) : SV_Target
            {
                // Timeを入力として現在の回転角度を作る
                half timer = _Time.x;
                // 回転行列を作る
                half angleCos = cos(timer * _RotateSpeed);
                half angleSin = sin(timer * _RotateSpeed);
                /*       |cosΘ -sinΘ|
                  R(Θ) = |sinΘ  cosΘ|  2次元回転行列の公式*/
                half2x2 rotateMatrix = half2x2(angleCos, -angleSin, angleSin, angleCos);
                //中心合わせ
                half2 uv1 = i.uv1-0.5;
                // 中心を起点にUVを回転させる
                i.uv1 = mul(uv1, rotateMatrix) + 0.5;
                //マスク用画像のピクセルの色を計算
                fixed4 mask = tex2D(_MaskTex, i.uv2);
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