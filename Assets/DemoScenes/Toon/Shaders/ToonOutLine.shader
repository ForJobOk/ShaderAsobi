Shader "Custom/ToonOutLine"
{
    Properties
    {
        //外のShader内のパスで利用しているプロパティ
        _MainTexture ("Main Texture", 2D) = "white" {}
        _ShadowTexture ("Shadow Texture", 2D) = "white" {}
        _ShadowStrength("Shadow Strength",Range(0,1)) = 0.5
        //このShader内のパスで利用するプロパティ
        _OutlineWidth ("Outline width", Range (0.005, 0.05)) = 0.01
        [HDR]_OutlineColor ("Outline Color", Color) = (0,0,0,1)
        [Toggle(USE_VERTEX_EXPANSION)] _UseVertexExpansion("Use vertex for Outline", int) = 0
    }

    SubShader
    {
        //他のShaderのパスを利用
        UsePass "Custom/ToonLit/TOON"
        Pass
        {
            //他で利用できるようにしておく
            Name "OUTLINE"
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature USE_VERTEX_EXPANSION
            #include "UnityCG.cginc"

            float _OutlineWidth;
            float4 _OutlineColor;

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
            };

            //頂点シェーダー
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 n = 0;

                #ifdef USE_VERTEX_EXPANSION //モデルの頂点方向に拡大するパターン
                
                //モデルの原点からみた各頂点の位置ベクトルを計算
                float3 dir = normalize(v.vertex.xyz);
                //UNITY_MATRIX_IT_MVはモデルビュー行列の逆行列の転置行列
                //各頂点の位置ベクトルをモデル座標系からビュー座標系に変換し正規化
                n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, dir));
                
                #else //モデルの法線方向に拡大するパターン
                
                //法線をモデル座標系からビュー座標系に変換し正規化
                n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                
                #endif

                //ビュー座標系に変換した法線を投影座標系に変換　
                //アウトラインとして描画予定であるピクセルのXY方向のオフセット
                float2 offset = TransformViewToProjection(n.xy);
                o.pos.xy += offset * _OutlineWidth;
                return o;
            }

            //フラグメントシェーダー
            fixed4 frag(v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}