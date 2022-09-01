Shader "Custom/RecalculateNormal"
{
    Properties
    {
        //ここに書いたものがInspectorに表示される
        _MainColor("MainColor",Color) = (1,1,1,1)
        _DiffuseShade("Diffuse Shade",Range(0,1)) = 0.5
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
                float3 normal: NORMAL;
                float3 tangent: TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 ambient : COLOR0; //環境光
            };

            //変数の宣言　Propertiesで定義した名前と一致させる
            float4 _MainColor;
            float _DiffuseShade;

            v2f vert(appdata v)
            {
                v2f o;

                //接空間のベクトルの近傍点を作成
                float3 posT = v.vertex + v.tangent;
                float3 posB = v.vertex + normalize(cross(v.normal, v.tangent));
               
                //頂点を動かす
                v.vertex.y = v.vertex.y + sin(v.vertex.x * 2.0 + _Time.y) * cos(v.vertex.z * 2.0 + _Time.y);

                //近傍値も動かす
                posT.y = posT.y + sin(posT.x * 2.0 + _Time.y) * cos(posT.z * 2.0 + _Time.y);
                posB.y = posB.y + sin(posB.x * 2.0 + _Time.y) * cos(posB.z * 2.0 + _Time.y);
                
                //動かした頂点座標と近傍点で接空間のベクトルを再計算する
                float3 modifiedTangent = posT - v.vertex;
                float3 modifiedBinormal = posB - v.vertex;
                
                //計算した接空間のベクトルを用いて法線を再計算する
                o.normal = normalize(cross(modifiedTangent, modifiedBinormal));
                o.vertex = UnityObjectToClipPos(v.vertex);
                //環境光
                o.ambient = ShadeSH9(float4(o.normal, 1));
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                //ライトの方向
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //Diffuse処理
                float4 diffuseColor = max(0, dot(i.normal, lightDir) * _DiffuseShade + (1 - _DiffuseShade));
                //色を乗算
                float4 finalColor = _MainColor * diffuseColor * _LightColor0 * float4(i.ambient, 0);
                return finalColor;
            }
            ENDCG
        }
    }
}