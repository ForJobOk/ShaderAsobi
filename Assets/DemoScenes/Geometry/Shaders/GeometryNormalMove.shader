Shader "Custom/GeometryNormalMove"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _PositionFactor("Position Factor", float) = 0.5
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
            float _PositionFactor;

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
                // 法線を計算
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                [unroll] //繰り返す処理を畳み込んで最適化してる？
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    //法線ベクトルに沿って頂点を移動
                    v.vertex.xyz += normal * (sin(_Time.w) + 0.5) * _PositionFactor;
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