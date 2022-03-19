Shader "Custom/ToonLit"
{
    Properties
    {
        _MainTexture ("Main Texture", 2D) = "white" {}
        _ShadowTexture ("Shadow Texture", 2D) = "white" {}
        _ShadowStrength("Shadow Strength",Range(0,1)) = 0.5
    }

    SubShader
    {
        Pass
        {
            Name "TOON"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTexture;
            sampler2D _ShadowTexture;
            float _ShadowStrength;

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            //頂点シェーダー
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //法線方向のベクトル
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            //フラグメントシェーダー
            fixed4 frag(v2f i) : SV_Target
            {
                //1つ目のライトのベクトルを正規化
                float3 l = normalize(_WorldSpaceLightPos0.xyz);
                //ワールド座標系の法線を正規化
                float3 n = normalize(i.worldNormal);
                //内積でLerpの補間値を計算　0以下の場合のみ補間値を利用する
                float interpolation = step(dot(n, l),0);
                //絶対値で正数にすることで影の領域を塗分ける
                float2 absD = abs(dot(n, l));
                //影の領域のテクスチャをサンプリング
                float3 shadowColor = tex2D(_ShadowTexture, absD).rgb;
                //メインのテクスチャをサンプリング
                float3 mainColor = tex2D(_MainTexture, i.uv).rgb;
                //補間値を用いて色を塗分け　影の強さ(影テクスチャーの濃さ)もここで調整
                float3 finalColor = lerp(mainColor, shadowColor * (1 - _ShadowStrength) * mainColor,interpolation);
                return float4(finalColor,1);
            }
            ENDCG
        }
    }
}