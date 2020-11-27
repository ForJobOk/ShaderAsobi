﻿Shader "Custom/NightSky"
{
    Properties
    {
        _SquareNum ("SquareNum", int) = 10
        _StarColor("StarColor",Color) = (0,0,0,0)
        _NightColor("NightColor",Color) = (0,0,0,0)
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
            int _SquareNum;
            float4 _StarColor;
            float4 _NightColor;

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
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
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

                uv *= _SquareNum; //格子状のマス目作成 UVにかけた数分だけ同じUVが繰り返し展開される

                float2 ist = floor(uv); //マス目の起点
                float2 fst = frac(uv); //点の位置

                float dist = 1;
                float4 randColor = 0;

                //自身含む周囲のマスを探索
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        //マスの起点(0,0)
                        float2 neighbor = float2(x, y);

                        //マスの起点を基準にした白点のxy座標
                        float2 p = 0.5 + 0.5 * random2(ist + neighbor);

                        //白点と処理対象のピクセルとの距離ベクトル
                        float2 diff = neighbor + p - fst;

                        //白点との距離が短くなれば更新
                        dist = min(dist, length(diff));

                        //色を星ごとにランダムに当てはめる　星の座標を利用
                        float r = rand(p+1);
                        float g = rand(p+2);
                        float b = rand(p+3);

                        randColor = float4(r, g, b, 1);
                    }
                }

                //補間値を計算
                //step(t,x) はtがxより大きい場合1を返す
                float interpolation = 1 - step(0.01, dist);

                //補間値を利用して夜空と星を塗り分け
                return lerp(_NightColor, randColor, interpolation);
            }
            ENDCG
        }
    }
}