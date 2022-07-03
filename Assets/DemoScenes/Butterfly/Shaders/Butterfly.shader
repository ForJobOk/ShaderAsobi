Shader "Custom/Butterfly"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [HDR]_MainColor("MainColor",Color) = (1,1,1,1)
        _FlapSpeed ("Flap Speed", Range(0,20)) = 10
        _FlapIntensity ("Flap Intensity", Range(0,2)) = 1
        _MoveSpeed ("Move Speed", Range(0,5)) = 1
        _MoveIntensity ("Move Intensity", Range(0,1)) = 0.2
        _RandomFlap ("Random Flap", Range(1,2)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Tansparent"
        }

        Pass
        {
            Cull off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float2 uv : TEXCOORD0;
                //中心座標を受け取る変数
                float3 center : TEXCOORD1;
                //ランダムな値を受け取る変数
                float random : TEXCOORD2;
                //速度を受け取る変数
                float3 velocity : TEXCOORD3;
                float4 color : COLOR;
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainColor;
            float _FlapSpeed;
            float _FlapIntensity;
            float _MoveIntensity;
            float _MoveSpeed;
            float _RandomFlap;

            //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            //非線形ブラウン運動を計算する
            float fbm(float x, float t)
            {
                return sin(x + t) + 0.5 * sin(2.0 * x + t) + 0.25 * sin(4.0 * x + t);
            }

            v2f vert(appdata v)
            {
                v2f o;

                //ローカル座標
                //Particle SystemのGameObjectが存在するところが原点となり、vertexにはこの原点から見た座標が入ってくる
                //そのため、パーティクルの中心座標を引いて計算を行い、もとに戻すという工程を踏む
                float3 local = v.vertex - v.center;

                //ランダムな値を計算
                float randomFlap = lerp(_FlapSpeed / _RandomFlap, _FlapSpeed, rand(v.random));
                float flap = (sin(_Time.w * randomFlap) + 0.5) * 0.5 * _FlapIntensity;
                //Sign(x)はxが0より大きい場合は1、小さい場合は-1を返す
                //これにより、x=0となる箇所から線対称に回転を計算できる
                half c = cos(flap * sign(local.x));
                half s = sin(flap * sign(local.x));
                /*       |cosΘ -sinΘ|
                  R(Θ) = |sinΘ  cosΘ|  2次元回転行列の公式*/
                half2x2 rotateMatrix = half2x2(c, -s, s, c);

                //羽の回転を反映
                local.xy = mul(rotateMatrix, local.xy);

                //進行方向を向かせるための回転行列を作成
                //正面は進行方向、すなわちParticleから取得したvelocity
                float3 forward = normalize(v.velocity);
                float3 up = float3(0, 1, 0);
                float3 right = normalize(cross(forward, up));

                //行列を作成
                //どうやら変数に詰めるときだけ行オーダーになっている？っぽい
                //なのでtransposeで転置を行う
                //すなわち以下でも可
                //float3x3 mat = float3x3(right.x,up.x,forward.x,
                //                        right.y,up.y,forward.y,
                //                        right.z,up.z,forward.z);
                float3x3 mat = transpose(float3x3(right, up, forward));

                //Velocity(正面方向)に応じた回転を反映
                v.vertex.xyz = mul(mat, local);

                //原点をもとの座標に戻す
                v.vertex.xyz += v.center;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //上下の移動量を求めて反映 ワールド座標系で上下移動させる
                float move = fbm(87034 * v.random, _Time.w * _MoveSpeed) * _MoveIntensity;
                o.vertex.y += move;
                o.uv = v.uv;
                //頂点カラー
                o.color = v.color;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                //PlaneのZ軸が正の方向になるようにテクスチャーをサンプリング
                //テクスチャーをRepeatにしておく必要あり
                float4 col = tex2D(_MainTex, -i.uv);
                col.rgb *= _MainColor.rgb;
                //頂点カラーを適用　これでParticleの色を拾うようになる
                col *= i.color;
                //重なったところが透明に切り抜かれてしまうので透過領域をClipしておく
                clip(col.a - 0.01);
                return col;
            }
            ENDCG
        }
    }
}