Shader "Custom/Fresnel"
{
    Properties
    {
        //ここに書いたものがInspectorに表示される
        _MainColor("MainColor",Color) = (1,1,1,1)
        _Reflection("Reflection", Range(0, 11)) = 1
        _F0 ("F0", Range(0.0, 0.3)) = 0.02
        _Frequency("Frequency ", Range(0, 20)) = 5 //周波
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
                float3 worldPos : WORLD_POS;
            };

            //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            //変数の宣言　Propertiesで定義した名前と一致させる
            float4 _MainColor;
            float _Reflection;
            float _F0;
            float _Frequency;

            //波のうねうね
            float Wave(float3 position)
            {
                float random1 = rand(position.xy);
                float random2 = rand(position.xz);
                return position.y + sin(position.x * _Frequency + _Time.y) * cos(position.z * _Frequency + _Time.y) * random1 * random2 * 0.3;
            }

            v2f vert(appdata v)
            {
                v2f o;

                //接空間のベクトルの近傍点を作成
                float3 posT = v.vertex + v.tangent;
                float3 posB = v.vertex + normalize(cross((v.normal), v.tangent));
                
                //頂点を動かす
                v.vertex.y = Wave(v.vertex);

                //近傍値も動かす
                posT.y = Wave(posT);
                posB.y = Wave(posB);

                //動かした頂点座標と近傍点で接空間のベクトルを再計算する
                float3 modifiedTangent = posT - v.vertex;
                float3 modifiedBinormal = posB - v.vertex;

                //計算した接空間のベクトルを用いて法線を再計算する
                o.normal = normalize(cross(modifiedTangent, modifiedBinormal));
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
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
                dotVR = max(0, dotVR);
                dotVR = pow(dotVR, 10 - _Reflection);
                //スペキュラーカラー計算
                float3 specular = _LightColor0.xyz * dotVR;
                //フレネル計算
                float vdotn = dot(viewDir, i.normal);
                half fresnel = _F0 + (1.0h - _F0) * pow(1.0h - vdotn, 5);
                //最終的な色を計算
                float4 finalColor = _MainColor + float4(specular * fresnel, 1);
                return finalColor;
            }
            ENDCG
        }
    }
}