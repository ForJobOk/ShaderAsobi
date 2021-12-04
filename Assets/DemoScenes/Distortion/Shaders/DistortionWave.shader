Shader "Custom/DistortionWave"
{
    Properties
    {
        _SquareNum ("SquareNum", int) = 5
        _DistortionPower("Distortion Power", Range(0, 0.1)) = 0
        [HDR]_WaterColor("WaterColor", Color) = (0,0,0,0)
        _DepthFactor("Depth Factor", Range(0, 10)) = 1.0
        _WaveSpeed("WaveSpeed", Range(1,10)) = 1
        _FoamPower("FoamPower", Range(0,1)) = 0.6
        _FoamColor("FoamColor", Color) = (1, 1, 1, 1)
        _EdgeColor("EdgeColor", Color) = (1, 1, 1, 1)
        _Frequency("Frequency ", Range(0, 3)) = 1
        _Amplitude("Amplitude", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "RenderType" = "Transparent"
        }

        //不当明度を利用するときに必要 文字通り、1 - フラグメントシェーダーのAlpha値　という意味
        Blend SrcAlpha OneMinusSrcAlpha

        //描画結果をテクスチャーとして取得可能に
        GrabPass
        {
            //ここで定義した名前で取得可能になる
            "_GrabPassTextureForDistortionWave"
        }
        
        //パスを跨いで活用できる変数や関数
        CGINCLUDE
        
        float _WaveSpeed;
        float _Amplitude;
        float _Frequency;

        #pragma vertex vert
        #pragma fragment frag
        
        #include "UnityCG.cginc"
        
        float vertex_wave(float2 vert,float waveSpeed,float amplitude,float frequency)
        {
             float2 factors = _Time.x * waveSpeed + vert * frequency;
             float2 offsetYFactors = sin(factors) * amplitude;
             return  offsetYFactors.x + offsetYFactors.y;
        }
        ENDCG

        //揺らぎの表現を頑張る　描画結果を利用する
        Pass
        {

            CGPROGRAM

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float4 scrPos : TEXCOORD2;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _GrabPassTextureForDistortionWave;
            float _DistortionPower;
            
            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                
                v.vertex.y += vertex_wave(v.vertex.xz,_WaveSpeed,_Amplitude,_Frequency);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                //ComputeScreenPosによってxyが0〜wに変換される
                o.scrPos = ComputeScreenPos(o.vertex);

                return o;
            }

           fixed4 frag(v2f i) : SV_Target
            {
                //サンプリングするUVをずらす sin波でゆらゆら
                float2 distortion = sin(i.uv.y * 50 + _Time.w) * 0.1f;
                distortion *= _DistortionPower;
                float4 depthUV = i.grabPos;
                //サンプリング用のUVによる歪みは少し大きくしておく
                //https://catlikecoding.com/unity/tutorials/flow/looking-through-water/
                depthUV.xy = i.grabPos.xy + distortion * 1.5f;
                //深度テクスチャをサンプリング
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(depthUV));
                //既に描画済みのピクセルの深度情報
                float backgroundDepth = LinearEyeDepth(depthSample);
                //今描画しようとしているピクセルの深度情報
                float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.scrPos.z);
                //Depthの差を利用した補間値
                float depthDiff = saturate(backgroundDepth - surfaceDepth);

                //w除算　普段はGPUが勝手にやってくれる
                //補間値を利用してUVをずらして良いピクセルとそのままにするピクセルを塗り分け
                float2 uv = (i.grabPos.xy + distortion * depthDiff) / i.grabPos.w;

                return tex2D(_GrabPassTextureForDistortionWave, uv);
            }
            ENDCG
        }
        
        //泡の表現を頑張る
        Pass
        {
            CGPROGRAM

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 scrPos : TEXCOORD1;
            };

            float4 _WaterColor;
            int _SquareNum;
            float _FoamPower;
            float4 _FoamColor;
            float4 _EdgeColor;
            float _DepthFactor;
            sampler2D _CameraDepthTexture;

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            v2f vert(appdata v)
            {
                v2f o = (v2f)0;

                v.vertex.y += vertex_wave(v.vertex.xz,_WaveSpeed,_Amplitude,_Frequency);;
                o.vertex = UnityObjectToClipPos(v.vertex);
                 //ComputeScreenPosによってxyが0〜wに変換される
                o.scrPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
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
                        float2 p = 0.5 + 0.5 * sin(random2(ist + neighbor) + _Time.x * _WaveSpeed);

                        //点と処理対象のピクセルとの距離ベクトル
                        float2 diff = neighbor + p - fst;

                        m_dist = min(m_dist, length(diff));

                        waveColor = lerp(_WaterColor, _FoamColor, smoothstep(1 - _FoamPower, 1, m_dist));
                    }
                }

                //深度テクスチャをサンプリング
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos));
                //スクリーンに描画されるピクセルの深度情報
                float screenDepth = LinearEyeDepth(depthSample) - i.scrPos.w;
                float edge = 1 - saturate(_DepthFactor * screenDepth);
                float4 color = lerp(waveColor, _EdgeColor, edge);
                return color;
            }
            ENDCG
        }
    }
}