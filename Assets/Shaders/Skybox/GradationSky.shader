Shader "Custom/GradationSky"
{
    Properties
    {
        //グラデーションカラー
        _TopColor("TopColor",Color) = (0,0,0,0)
        _UnderColor("UnderColor",Color) = (0,0,0,0)

        //色の境界の位置
        _ColorBorder("ColorBorder",Range(0,3)) = 0.5
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
            float4 _UnderColor;
            float4 _TopColor;
            float _ColorBorder;

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

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)), dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            float4 frag(v2f i) : SV_Target
            {
                //描画したいピクセルのワールド座標を正規化
                float3 dir = normalize(i.worldPos);
                //ラジアンを算出する
                //atan2(x,y) 直行座標の角度をラジアンで返す
                //atan(x)と異なり、1周分の角度をラジアンで返せる　今回はスカイボックスの円周上のラジアンが返される
                //asin(x)  -π/2～π/2の間で逆正弦を返す　xの範囲は-1～1
                float2 rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                float2 uv = rad / float2(2.0 * UNITY_PI, UNITY_PI / 2);

                //整えたUVのY軸方向の座標を利用して色をグラデーションさせる
                return lerp(_UnderColor, _TopColor, uv.y + _ColorBorder);
            }
            ENDCG
        }
    }
}