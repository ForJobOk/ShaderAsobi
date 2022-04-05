Shader "Custom/BlendOcclusion"
{
    Properties
    {
        //ToonOutLineのパスで利用しているProperty
        _OutlineWidth ("Outline width", Range (0.005, 0.05)) = 0.01
        [HDR]_OutlineColor ("Outline Color", Color) = (0,0,0,1)
        [Toggle(USE_VERTEX_EXPANSION)] _UseVertexExpansion("Use vertex for Outline", int) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="geometry-1"
        }

        //フラグメントシェーダーのAlpha値が0の場合、最終的な描画結果はカラーバッファに既に書き込まれている値になる
        //計算式 → 1 × フラグメントシェーダーの出力 + (1 - フラグメントシェーダーの出力するアルファ値) ×　カラーバッファに既に書き込まれている値
        //結果 → 1 × 0 + (1 - 0) ×　カラーバッファに既に書き込まれている値 = カラーバッファに既に書き込まれている値　つまりそのまま
        Blend One OneMinusSrcAlpha

        //フラグメントシェーダーのAlpha値が1の場合、最終的な描画結果はカラーバッファに既に書き込まれている値になる
        //計算式 → 0 × フラグメントシェーダーの出力 + フラグメントシェーダーの出力するアルファ値 ×　カラーバッファに既に書き込まれている値
        //結果 → 0 × 1 + 1 ×　カラーバッファに既に書き込まれている値 = カラーバッファに既に書き込まれている値　つまりそのまま
        //Blend Zero SrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex:POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(v2f i) : COLOR
            {
                //最終的なAlpha値が0
                return 0;
                //最終的なAlpha値が1
                //return 1;
            }
            ENDCG
        }

        //他のShaderのパスを利用
        UsePass "Custom/ToonOutLine/OUTLINE"
    }
}