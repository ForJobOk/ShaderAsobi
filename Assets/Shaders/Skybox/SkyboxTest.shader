Shader "Custom/SkyboxTest"
{
    Properties
    {
        //スクロールさせるテクスチャ
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Background" //最背面に描画するのでBackground
            "Queue"="Background" //最背面に描画するのでBackground
            "PreviewType"="SkyBox" //設定すればマテリアルのプレビューがスカイボックスになるらしい
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            //変数の宣言　Propertiesで定義した名前と一致させる
            sampler2D _MainTex;

            //GPUから頂点シェーダーに渡す構造体
            struct appdata
            {
                float4 vertex: POSITION;
            };

            //頂点シェーダーからフラグメントシェーダーに渡す構造体
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };
            
            v2f vert(appdata v)
            {
                v2f o;
                //mulは行列の掛け算をやってくれる関数
                o.worldPos = v.vertex.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }


            float4 frag(v2f i) : SV_Target
            {
                //描画したいピクセルのワールド座標を正規化
                float3 dir = normalize(i.worldPos);
                //ラジアンを算出する
                //atan2(x,y) 二点間の角度がラジアンとして返る
                //atan(x)と異なり、1周分の角度をラジアンで返せる　今回はスカイボックスの円周上の角度が返される
                //asin(x)  -π/2～π/2の間で逆正弦を返す　
                float2 rad = float2(atan2(dir.x, dir.z)/UNITY_PI/2, asin(dir.y)/UNITY_PI*2);
                //今回はスカイボックスの円周上の角度に対して　π×2
                float2 uv = rad / float2(2.0 * UNITY_PI, UNITY_PI/2);
                //テクスチャとUV座標から色の計算を行う
                float4 col = tex2D(_MainTex, rad);
                return float4(col);
            }
            ENDCG

        }
    }
}