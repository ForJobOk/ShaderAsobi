Shader "Custom/Hex"
{
    Properties
    {
        [HDR]_MainColor("MainColor", Color) = (1, 1, 1, 1)
        _RepeatFactor ("RepeatFactor", Range(0,100)) = 50
        _DistanceInterpolation ("DistanceInterpolation", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Tranparent" }
        //不当明度を利用するときに必要 文字通り、1 - フラグメントシェーダーのAlpha値　という意味
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
            };

            float4 _MainColor;
            float _RepeatFactor;
            float _DistanceInterpolation;

            //UVから六角形タイルを出力
            float hex(float2 uv, float scale = 1)
            {
                float2 p = uv * scale;
                p.x *= 1.15470053838; // x座標を2/√3倍 (六角形の横方向の大きさが√3/2倍になる)
                float isTwo = frac(floor(p.x) / 2.0) * 2.0; // 偶数列目なら1.0
                p.y += isTwo * 0.5; // 偶数列目を0.5ずらす  
                p = frac(p) - 0.5; 
                p = abs(p); // 上下左右対称にする
                // 六角形タイルとして出力
                return  abs(max(p.x*1.5 + p.y, p.y*2.0) - 1.0);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex); //ローカル座標系をワールド座標系に変換
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // カメラとオブジェクトの距離(長さ)を取得
                // _WorldSpaceCameraPos：定義済の値　ワールド座標系のカメラの位置
                float cameraToObjLength = length(_WorldSpaceCameraPos - i.worldPos);
                
                float interpolation = hex(i.uv,_RepeatFactor);
                float3 finalColor = lerp(_MainColor,0,interpolation);
                float alpha = lerp(1,0,interpolation);
                alpha *= lerp(1,0,cameraToObjLength*_DistanceInterpolation);
                clip(alpha);
                return float4(finalColor,alpha);
            }
            ENDCG
        }
    }
}
