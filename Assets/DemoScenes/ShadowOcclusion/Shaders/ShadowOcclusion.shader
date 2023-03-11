Shader "Custom/ShadowOcclusion"
{
    Properties
    {
        _ShadowIntensity ("Shadow Intensity", Range (0, 1)) = 0.6

        //ToonOutLineのパスで利用しているProperty
        _OutlineWidth ("Outline width", Range (0.005, 0.05)) = 0.01
        [HDR]_OutlineColor ("Outline Color", Color) = (0,0,0,1)
        [Toggle(USE_VERTEX_EXPANSION)] _UseVertexExpansion("Use vertex for Outline", int) = 0
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "Queue"="geometry-1"
                "LightMode" = "ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            
            float _ShadowIntensity;
            //グローバル変数
            float _ShadowDistance;

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos : WORLD_POS;
                SHADOW_COORDS(1)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //影の計算のマクロ
                TRANSFER_SHADOW(o);
                //法線方向のベクトル
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag(v2f i) : COLOR
            {
                // カメラとオブジェクトの距離(長さ)を取得
                // _WorldSpaceCameraPos：定義済の値　ワールド座標系のカメラの位置
                float cameraToObjLength = clamp(length(_WorldSpaceCameraPos - i.worldPos), 0, _ShadowDistance);
                //1つ目のライトのベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                //ワールド座標系の法線を正規化
                float3 N = normalize(i.worldNormal);
                //内積の結果が0以上なら1 この値を使って裏側の影は描画しない
                float front = step(0, dot(N, L));
                //影の場合0、それ以外は1
                float attenuation = SHADOW_ATTENUATION(i);
                //影の減衰率
                float fade = 1 - pow(cameraToObjLength / _ShadowDistance, _ShadowDistance);
                return float4(0, 0, 0, (1 - attenuation) * _ShadowIntensity * front * fade);
            }
            ENDCG
        }
        
        //影を落とす処理を行うPass
        Pass
        {
            Tags
            {
                "LightMode"="ShadowCaster"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        //他のShaderのパスを利用
        UsePass "Custom/ToonOutLine/OUTLINE"
    }
}