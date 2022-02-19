Shader "Custom/GeometryWireFrame"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
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
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;

            //頂点シェーダーに渡ってくる頂点データ
            struct appdata
            {
                float4 vertex : POSITION;
            };

            //ジオメトリシェーダーからフラグメントシェーダーに渡すデータ
            struct g2f
            {
                float4 vertex : SV_POSITION;
            };

            //頂点シェーダー
            appdata vert(appdata v)
            {
                return v;
            }

            //ジオメトリシェーダー
            [maxvertexcount(3)] 
            void geom(triangle appdata input[3], inout LineStream<g2f> stream)
            {
                [unroll] //繰り返す処理を畳み込んで最適化してる？
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    stream.Append(o);
                }
            }

            //フラグメントシェーダー
            fixed4 frag(g2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}