Shader "Custom/Border"
{
   Properties
    {
        _SquareNum ("SquareNum", int) = 5
        [HDR]_WaterColor("WaterColor", Color) = (0.09, 0.89, 1, 1)
        _WaveSpeed("WaveSpeed", Range(1,10)) = 1
        _FoamPower("FoamPower", Range(0,1)) = 0.6
        _FoamColor("FoamColor", Color) = (1, 1, 1, 1)
        _EdgeColor("EdgeColor", Color) = (1, 1, 1, 1)
        _DepthFactor("Depth Factor", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            uniform sampler2D _CameraDepthTexture;
            int _SquareNum;
            fixed4 _WaterColor;
            fixed4 _FoamColor; 
            fixed4 _EdgeColor;
            float _WaveSpeed;
            float _FoamPower;
            float _DepthFactor;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 st = i.uv;
                st *= _SquareNum; //格子状のマス目作成 UVにかけた数分だけ同じUVが繰り返し展開される

                float2 ist = floor(st); //各マス目の起点
                float2 fst = frac(st); //各マス目の起点からの描画したい位置

                float4 waveColor = 0;
                float m_dist = 100;

                //自身含む周囲のマスを探索
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        //周辺1×1のエリア
                        float2 neighbor = float2(x, y);

                        //点のxy座標
                        float2 p =  0.5 + 0.5 * sin(random2(ist+neighbor) +_Time.x *_WaveSpeed);

                        //点と処理対象のピクセルとの距離ベクトル
                        float2 diff = neighbor + p - fst;

                        m_dist = min(m_dist, length(diff));

                        waveColor =  lerp(_WaterColor,_FoamColor,smoothstep(_FoamPower,1,m_dist));
                    }
                }
                
                //深度の計算　おまじない
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                half depth = LinearEyeDepth(depthSample);
                half screenDepth = depth - i.screenPos.w;
                float edgeLine = 1 - saturate(_DepthFactor * screenDepth);
                fixed4 finalColor = lerp(waveColor, _EdgeColor, edgeLine);
                
                return finalColor;
            }
            ENDCG
        }
    }
}