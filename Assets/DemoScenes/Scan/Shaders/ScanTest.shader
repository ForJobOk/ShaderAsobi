Shader "Custom/Scan"
{
    Properties
    {
        [HDR]_LineColor("Scan Line Color", Color) = (1,1,1,1)
        [HDR]_TrajectoryColor("Scan Trajectory Color", Color) = (0.3, 0.3, 0.3, 1)
        _LineSpeed("Scan Line Speed", Float) = 1.0
        _LineSize("Scan Line Size", Float) = 0.02
        _TrajectorySize("Scan Trajectory Size", Float) = 1.0
        _IntervalSec("Scan Interval", Float) = 2.0
        _MaxAlpha("Max Alpha", Range(0,1)) = 0.5
        _TrajectoryAlpha("Trajectory Alpha", Range(0.1,1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent"
        }
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
                float3 worldPos : WORLD_POS;
                float3 viewT : TEXCOORD1;
            };

            float4 _LineColor;
            float _LineSpeed;
            float _LineSize;
            float4 _TrajectoryColor;
            float _TrajectorySize;
            float _IntervalSec;
            float _MaxAlpha;
            float _TrajectoryAlpha;
            
            //C#から受け取る
            float _TimeFactor;

            v2f vert(appdata v)
            {
                v2f o;
                //unity_ObjectToWorld × 頂点座標(v.vertex) = 描画しようとしてるピクセルのワールド座標　らしい
                //mulは行列の掛け算をやってくれる関数
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewT = mul((float3x3)UNITY_MATRIX_V,float3(0,0,1));
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float timeDelta = (_TimeFactor * _LineSpeed);
                //カメラの正面方向にエフェクトを進める
                //UNITY_MATRIX_V[2].xyzでWorldSpaceのカメラの向きが取得できる
                float direction = normalize(UNITY_MATRIX_V[2].xyz);
                
                return color;
            }
            ENDCG
        }
    }
}