Shader "Custom/SimpleDiffuse"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0, 0, 0, 1)
        _DiffuseShade("Diffuse Shade",Range(0,1)) = 0.5
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _MainColor;
            float _DiffuseShade;

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                half3 worldNormal:TEXCOORD0;
            };

            //頂点シェーダー
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //法線方向のベクトル
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            //フラグメントシェーダー
            fixed4 frag(v2f i) : SV_Target
            {
                //1つ目のライトのベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                //ワールド座標系の法線を正規化
                float3 N = normalize(i.worldNormal);
                //ライトベクトルと法線の内積からピクセルの明るさを計算 ランバートの調整もここで行う
                fixed4 diffuseColor = max(0, dot(N, L) * _DiffuseShade + (1 - _DiffuseShade));
                //色を乗算
                fixed4 finalColor = _MainColor * diffuseColor;
                return finalColor;
            }
            ENDCG
        }
    }
}