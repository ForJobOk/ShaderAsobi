Shader "Tessellation"
{

    Properties
    {
        _Color("Color", color) = (1, 1, 1, 0)
        _MainTex("Base (RGB)", 2D) = "white" {}
        _DispTex("Disp Texture", 2D) = "gray" {}
        _MinDist("Min Distance", Range(0.1, 50)) = 10
        _MaxDist("Max Distance", Range(0.1, 50)) = 25
        _TessFactor("Tessellation", Range(1, 50)) = 10
        _Displacement("Displacement", Range(0, 1.0)) = 0.3
    }

    SubShader
    {

        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert //vertが頂点シェーダーであることをGPUに伝える
            #pragma fragment frag //fragがフラグメントシェーダーであることをGPUに伝える
            #pragma hull hull //hullがハルシェーダーであることをGPUに伝える
            #pragma domain domain //domainがドメインシェーダーであることをGPUに伝える

            #include "Tessellation.cginc"
            #include "UnityCG.cginc"

            //定数を定義
            #define INPUT_PATCH_SIZE 3
            #define OUTPUT_PATCH_SIZE 3

            float _TessFactor;
            float _Displacement;
            float _MinDist;
            float _MaxDist;
            sampler2D _DispTex;
            sampler2D _MainTex;
            fixed4 _Color;

            //GPUから頂点シェーダーに渡す構造体
            struct appdata
            {
                float3 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            //頂点シェーダーからハルシェーダーに渡す構造体
            struct HsInput
            {
                float4 f4Position : POS;
                float3 f3Normal : NORMAL;
                float2 f2TexCoord : TEXCOORD;
            };

            //ハルシェーダーからドメインシェーダーに渡す構造体
            struct HsControlPointOutput
            {
                float3 f3Position : POS;
                float3 f3Normal : NORMAL;
                float2 f2TexCoord : TEXCOORD;
            };

            struct HsConstantOutput
            {
                float fTessFactor[3] : SV_TessFactor;
                float fInsideTessFactor : SV_InsideTessFactor;
            };

            //ドメインシェーダーからフラグメントシェーダーに渡す構造体
            struct DsOutput
            {
                float4 f4Position : SV_Position;
                float2 f2TexCoord : TEXCOORD0;
            };

            //頂点シェーダー
            HsInput vert(appdata i)
            {
                HsInput o;
                o.f4Position = float4(i.vertex, 1.0);
                o.f3Normal = i.normal;
                o.f2TexCoord = i.texcoord;
                return o;
            }

            //ハルシェーダー
            //パッチ：ポリゴン分割処理を行う際に使用する頂点分割で使う制御点の集合
            //パッチを元にどうやって分割するか計算する
            [domain("tri")] //分割に利用する形状を指定　"tri" "quad" "isoline"から選択
            [partitioning("integer")] //分割方法 "integer" "fractional_eve" "fractional_odd" "pow2"から選択
            [outputtopology("triangle_cw")] //出力された頂点が形成するトポロジー(形状)　"point" "line" "triangle_cw" "triangle_ccw" から選択
            [patchconstantfunc("hullConst")] //Patch-Constant-Functionの指定
            [outputcontrolpoints(OUTPUT_PATCH_SIZE)]
            HsControlPointOutput hull(InputPatch<HsInput, INPUT_PATCH_SIZE> i, uint id : SV_OutputControlPointID)
            {
                HsControlPointOutput o = (HsControlPointOutput)0;
                o.f3Position = i[id].f4Position.xyz;
                o.f3Normal = i[id].f3Normal;
                o.f2TexCoord = i[id].f2TexCoord;
                return o;
            }

            //Patch-Constant-Function
            //どの程度頂点を分割するかを決める係数を詰め込んでテッセレーターに渡す
            HsConstantOutput hullConst(InputPatch<HsInput, INPUT_PATCH_SIZE> i)
            {
                HsConstantOutput o = (HsConstantOutput)0;

                float4 p0 = i[0].f4Position;
                float4 p1 = i[1].f4Position;
                float4 p2 = i[2].f4Position;
                float4 tessFactor = UnityDistanceBasedTess(p0, p1, p2, _MinDist, _MaxDist, _TessFactor);

                o.fTessFactor[0] = tessFactor.x;
                o.fTessFactor[1] = tessFactor.y;
                o.fTessFactor[2] = tessFactor.z;
                o.fInsideTessFactor = tessFactor.w;

                return o;
            }

            //ドメインシェーダー
            //テッセレーターから出てきた分割位置で頂点を計算し出力するのが仕事
            [domain("tri")]
            DsOutput domain(
                HsConstantOutput hsConst,
                const OutputPatch<HsControlPointOutput, INPUT_PATCH_SIZE> i,
                float3 bary : SV_DomainLocation)
            {
                DsOutput o = (DsOutput)0;

                float3 f3Position =
                    bary.x * i[0].f3Position +
                    bary.y * i[1].f3Position +
                    bary.z * i[2].f3Position;

                float3 f3Normal = normalize(
                    bary.x * i[0].f3Normal +
                    bary.y * i[1].f3Normal +
                    bary.z * i[2].f3Normal);

                o.f2TexCoord =
                    bary.x * i[0].f2TexCoord +
                    bary.y * i[1].f2TexCoord +
                    bary.z * i[2].f2TexCoord;

                float disp = tex2Dlod(_DispTex, float4(o.f2TexCoord, 0, 0)).r * _Displacement;
                f3Position.xyz += f3Normal * disp;

                o.f4Position = UnityObjectToClipPos(float4(f3Position.xyz, 1.0));

                return o;
            }

            //フラグメントシェーダー
            fixed4 frag(DsOutput i) : SV_Target
            {
                return tex2D(_MainTex, i.f2TexCoord) * _Color;
            }
            ENDCG
        }
    }

    Fallback "Unlit/Texture"

}