Shader "Custom/GradationNightSkyWithMoon"
{
    Properties
    {
        _SquareNum ("SquareNum", int) = 10
        _MoonColor("MoonColor",Color) = (0,0,0,0)

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
            int _SquareNum;
            float4 _MoonColor;
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
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            //ランダムな値を返す
            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)), dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }


            float4 frag(v2f i) : SV_Target
            {
                //描画したいピクセルのローカル座標を正規化
                float3 dir = normalize(i.worldPos);
                //ラジアンを算出する
                //atan2(x,y) 直行座標の角度をラジアンで返す
                //atan(x)と異なり、1周分の角度をラジアンで返せる　今回はスカイボックスの円周上のラジアンが返される
                //asin(x)  -π/2～π/2の間で逆正弦を返す　xの範囲は-1～1
                float2 rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                float2 uv = rad / float2(UNITY_PI / 2, UNITY_PI / 2);

                uv *= _SquareNum; //格子状のマス目作成 UVにかけた数分だけ同じUVが繰り返し展開される

                float2 ist = floor(uv); //各マス目の起点
                float2 fst = frac(uv); //各マス目の起点からの描画したい位置

                float4 color = 0;

                //自身含む周囲のマスを探索
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        //周辺1×1のエリア
                        float2 neighbor = float2(x, y);

                        //点のxy座標
                        float2 p = random2(ist);

                        //点と処理対象のピクセルとの距離ベクトル
                        float2 diff = neighbor + p - fst;

                        //色を星ごとにランダムに当てはめる　星の座標を利用
                        float r = rand(p + 1);
                        float g = rand(p + 2);
                        float b = rand(p + 3);
                        float4 randColor = float4(r, g, b, 1);

                        //"点"と"現在描画しようとしているピクセルとの距離"を利用して星を描画するかどうかを計算
                        //step(t,x) はtがxより大きい場合1を返す
                        float interpolation = 1 - step(0.01, length(diff));
                        color = lerp(color, randColor, interpolation);
                    }
                }

                //整えたUVのY軸方向の座標を利用して色をグラデーションさせる
                color += lerp(_UnderColor, _TopColor, uv.y + _ColorBorder);
                //月
                color = lerp(_MoonColor, color, step(uv.y, _SquareNum * 0.75));

                //color.r += step(0.98, fst.x) + step(0.98, fst.y);

                return color;
            }
            ENDCG
        }
    }
}