Shader "Custom/Butterfly"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [HDR]_MainColor("MainColor",Color) = (1,1,1,1)
        _FlapSpeed ("Flap Speed", Range(0,10)) = 1
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
                //COLORを受け取る変数
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
            float4 _MainTex_ST;
            float _FlapSpeed;
            float _MoveSpeed;
            float _RandomFlap;
            float _FlapIntensity;
            float _MoveIntensity;
            float4 _MainColor;

             //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            float fbm(float x , float t)
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
                float randomFlap = lerp(_FlapSpeed/_RandomFlap,_FlapSpeed,rand(v.random));
                // 回転行列を作る
                float flap = (sin(_Time.w * randomFlap) +0.5) *0.5* _FlapIntensity;
                //Sign(x)はxが0より大きい場合は1、小さい場合は-1を返す
                //これにより、x=0となる箇所から線対称に回転を計算できる
                half c = cos(flap * sign(local.x));
                half s = sin(flap * sign(local.x));
                /*       |cosΘ -sinΘ|
                  R(Θ) = |sinΘ  cosΘ|  2次元回転行列の公式*/
                half2x2 rotateMatrix = half2x2(c, -s, s, c);
                
                //回転行列を適用
                local.xy = mul(rotateMatrix, local.xy);

                //回転量を求める
                float rot = abs(fbm(87034 * v.random,_Time.y));
                float3 up = (0,0,0);
                up.yz += rot;
                up = normalize(up);
                up = mul((float3x3)unity_ObjectToWorld,up);
               
                //中心座標をワールド座標に変換
                float3 worldPos = mul(unity_ObjectToWorld,float4(v.center,1));
                //正面は進行方向
                float3 forward = normalize(v.velocity);
                float3 right = normalize(cross(forward,up));
                up = normalize(cross(right,forward));

                //行列を作成
                float4x4 mat = (1,0,0,0, 0,1,0,0, 0,0,1,0 ,0,0,0,1);
                mat._m00_m10_m20 = right;
                mat._m01_m11_m21 = up;
                mat._m02_m12_m22 = forward;
                mat._m03_m13_m23 = worldPos;
                
                v.vertex = mul(mat,local);
        
                v.vertex.xyz += v.center;            
                o.vertex = UnityObjectToClipPos(v.vertex);
                 //上下の移動量を求めて反映
                float move = fbm(87034 * v.random,_Time.w * _MoveSpeed) * _MoveIntensity;
                o.vertex.y += move;
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                //PlaneのZ軸
                float4 col = tex2D(_MainTex, -i.uv);
                col.rgb *= _MainColor.rgb;
                col *= i.color;
                clip(col.a - 0.01);
                return col;
            }
            ENDCG
        }
    }
}