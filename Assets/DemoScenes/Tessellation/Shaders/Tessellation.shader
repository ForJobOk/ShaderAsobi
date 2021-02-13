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

        CGINCLUDE
        #include "Tessellation.cginc"
        #include "UnityCG.cginc"

        float _TessFactor;
        float _Displacement;
        float _MinDist;
        float _MaxDist;
        sampler2D _DispTex;
        sampler2D _MainTex;
        fixed4 _Color;

        struct VsInput
        {
            float3 vertex : POSITION;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        struct HsInput
        {
            float4 f4Position : POS;
            float3 f3Normal : NORMAL;
            float2 f2TexCoord : TEXCOORD;
        };

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

        struct DsOutput
        {
            float4 f4Position : SV_Position;
            float2 f2TexCoord : TEXCOORD0;
        };

        HsInput vert(VsInput i)
        {
            HsInput o;
            o.f4Position = float4(i.vertex, 1.0);
            o.f3Normal = i.normal;
            o.f2TexCoord = i.texcoord;
            return o;
        }

        [domain("tri")]
        [partitioning("integer")]
        [outputtopology("triangle_cw")]
        [patchconstantfunc("hullConst")]
        [outputcontrolpoints(3)]
        HsControlPointOutput hull(InputPatch<HsInput, 3> i, uint id : SV_OutputControlPointID)
        {
            HsControlPointOutput o = (HsControlPointOutput)0;
            o.f3Position = i[id].f4Position.xyz;
            o.f3Normal = i[id].f3Normal;
            o.f2TexCoord = i[id].f2TexCoord;
            return o;
        }

        HsConstantOutput hullConst(InputPatch<HsInput, 3> i)
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

        [domain("tri")]
        DsOutput domain(
            HsConstantOutput hsConst,
            const OutputPatch<HsControlPointOutput, 3> i,
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

        fixed4 frag(DsOutput i) : SV_Target
        {
            return tex2D(_MainTex, i.f2TexCoord) * _Color;
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma hull hull
            #pragma domain domain
            ENDCG
        }

    }

    Fallback "Unlit/Texture"

}