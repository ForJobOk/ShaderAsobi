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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
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
            float _AlphaFactor;

            v2f vert(appdata v)
            {
                v2f o;
                //unity_ObjectToWorld × 頂点座標(v.vertex) = 描画しようとしてるピクセルのワールド座標　らしい
                //mulは行列の掛け算をやってくれる関数
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float timeDelta = (_TimeFactor *_LineSpeed);
                //カメラの正面方向にエフェクトを進める
                //UNITY_MATRIX_V[2].xyzでWorldSpaceのカメラの向きが取得できる
                float direction = dot(i.worldPos,normalize(-UNITY_MATRIX_V[2].xyz));
                //進行方向に対して時間変化に伴い値を加算する
                float linePosition = abs(direction - timeDelta);
                //スキャンラインの大きさを計算　step(a,b) はbがaより大きい場合1を返す
                //すなわち、_LineSizeが大きくなればstepが1を返す値の範囲も大きくなる
                float scanline = step(linePosition,_LineSize);
                //軌跡の大きさを計算 smoothstep(a,b,c) はcがa以下の時は0、b以上の時は1、0～1は補間
                //1 - smoothstep(a,b,c)とすることで補間値を逆転できる　
                //つまり 1 - smoothstep(a,b,c) はcがa以上の時は1、b以下の時は0、0～1は補間
                float trajectory = 1 - smoothstep(_LineSize,_LineSize + _TrajectorySize, linePosition);
                //同様にして徐々に透過させる
                float alpha = 1 - smoothstep(_LineSize, (_LineSize + _TrajectorySize) *_TrajectoryAlpha, linePosition);
                //ここまでの計算結果を元に色を反映
                float4 color = _LineColor * scanline + _TrajectoryColor * trajectory;
                //透明度調整 clamp(a,b,c) aの値をb～cの間に収める
                color.a = clamp(alpha*_AlphaFactor,0, _MaxAlpha);
                return color;
            }
            ENDCG
        }
    }
}