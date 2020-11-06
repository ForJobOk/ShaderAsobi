Shader "Custom/GeometryScalable"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ScaleFactor ("Scale Factor", Range(0,1.0)) = 0.5
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
            float _ScaleFactor;

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
            //引数のinputは文字通り頂点シェーダーからの入力
            //streamは参照渡しで次の処理に値を受け渡ししている　TriangleStream<>で三角面を出力する
            [maxvertexcount(3)] //出力する頂点の最大数　正直よくわからない
            void geom(triangle appdata input[3], inout TriangleStream<g2f> stream)
            {
                //1枚のポリゴンの中心
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;

                [unroll] //繰り返す処理を畳み込んで最適化してる？
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    //中心を起点にスケールを変える
                    v.vertex.xyz = center + (v.vertex.xyz - center) * (1.0 - _ScaleFactor);
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