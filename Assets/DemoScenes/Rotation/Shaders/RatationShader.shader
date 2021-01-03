Shader "Custom/Rotation"
{
    //Inspectorに出すプロパティー
    Properties
    {
        //テクスチャー(オフセットの設定なし)
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
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
                float2 uv : TEXCOORD0; //1番目のUV座標　という意味らしい　なるほどわからん
            };

            //フラグメントシェーダーへ渡すデータ
            struct v2f
            {
                float2 uv : TEXCOORD0; //テクスチャUV
                float4 vertex : SV_POSITION; //座標変換された後の頂点座標
            };

            sampler2D _MainTex;
            float _RotateSpeed;

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
                // Timeを入力として現在の回転角度を作る
                half timer = _Time.x;
                // 回転行列を作る
                half angleCos = cos(timer * _RotateSpeed);
                half angleSin = sin(timer * _RotateSpeed);
                /*       |cosΘ -sinΘ|
                  R(Θ) = |sinΘ  cosΘ|  2次元回転行列の公式*/
                half2x2 rotateMatrix = half2x2(angleCos, -angleSin, angleSin, angleCos);
                //中心
                half2 uv = i.uv - 0.5;
                // 中心を起点にUVを回転させる
                i.uv = mul(uv, rotateMatrix) + 0.5;

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}