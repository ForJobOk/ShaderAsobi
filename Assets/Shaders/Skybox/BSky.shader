Shader "Custom/BSky"
{
    Properties
    {
        _SquareNum ("SquareNum", int) = 10
        _Brightness ("Brightness", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            int _SquareNum;
            float _Brightness;

            //GPUから頂点シェーダーに渡す構造体
            struct appdata
            {
                float4 uv: TEXCOORD0;
                float4 vertex: POSITION;
            };

            //頂点シェーダーからフラグメントシェーダーに渡す構造体
            struct v2f
            {
                float4 uv: TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            v2f vert(appdata v)
            {
                v2f o;
                //mulは行列の掛け算をやってくれる関数
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
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

            fixed4 frag (v2f i) : SV_Target
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

                float2 ist = floor(uv); //各マス目の起点
                float2 fst = frac(uv); //各マス目の起点からの点の位置

                float dist = 1;

                //自身含む周囲のマスを探索
                for (int y = -1; y <= 1; y++)
                for (int x = -1; x <= 1; x++)
                {
                    //マスの起点(0,0)
                    float2 neighbor = float2(x, y);

                    //マスの起点を基準にした白点のxy座標
                    float2 p = 0.5 + 0.5 * sin(_Time.y  + 6.2831 * random2(ist + neighbor));

                    //白点と処理対象のピクセルとの距離ベクトル
                    float2 diff = neighbor + p - fst;

                    //白点との距離が短くなれば更新
                    dist = min(dist, length(diff));
                }

                //白点から最も短い距離を色に反映
                return dist * _Brightness;
            }
            ENDCG
        }
    }
}