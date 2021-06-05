Shader "Custom/WorldNormal"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float3 tangent:TANGENT;
            };

            struct v2f
            {
                half3 normal : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            //頂点シェーダー
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //法線方向のベクトル
                //o.normal = v.normal; ローカル座標系の法線
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            //フラグメントシェーダー
            fixed4 frag(v2f i) : SV_Target
            {
                return float4(i.normal,1);
            }
            ENDCG
        }
    }
}