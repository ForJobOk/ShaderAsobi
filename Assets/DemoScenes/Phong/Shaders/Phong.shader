Shader "Custom/Phong"
{
      Properties
    {
        //ここに書いたものがInspectorに表示される
        _MainColor("MainColor",Color) = (1,1,1,1)
        _Reflection("Reflection", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPos : WORLD_POS;
            };

            //変数の宣言　Propertiesで定義した名前と一致させる
            float4 _MainColor;
            float _Reflection;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                //ライトの方向
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //ライトベクトルと法線ベクトルから反射ベクトルを計算
                float3 refVec = reflect(-lightDir, i.normal);
                //視線ベクトル
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                //視線ベクトルと反射ベクトルの内積を計算
                float dotVR = dot(refVec, viewDir);
                //0以下は利用しないように内積の値を再計算
                dotVR = max(0,dotVR);
                dotVR = pow(dotVR, _Reflection);
                float3 specular = _LightColor0.xyz * dotVR;
                //内積を補間値として塗分け
                float4 finalColor =  _MainColor + float4(specular,1);
                return finalColor;
            }
            ENDCG
        }
    }
}