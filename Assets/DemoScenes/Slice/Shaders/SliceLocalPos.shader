Shader "Custom/SliceLocalPos"
{
    Properties
    {
        //ここに書いたものがInspectorに表示される
        _Color("MainColor",Color) = (0,0,0,0)
        //スライスされる間隔
        _SliceSpace("SliceSpace",Range(0,30)) = 15
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType"="Opaque"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            //変数の宣言　Propertiesで定義した名前と一致させる
            half4 _Color;
            half _SliceSpace;

            struct v2f
            {
                //こいつ(pos)には3D→2D(スクリーン)座標変換された後の頂点座標をいれるぜ！ってGPUに教える
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
            };

            v2f vert(appdata_base v) //appdata_baseはUnityCG.cgincで定義されている構造体
            {
                v2f o;
                //描画しようとしているピクセル(ローカル座標？)
                o.localPos = v.vertex.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                //各ピクセルのローカル座標(Y軸)それぞれに15をかけてfrac関数で少数だけ取り出す
                //そこから-0.5してclip関数で0を下回ったら描画しない
                clip(frac(i.localPos.y * _SliceSpace) - 0.5);
                //RGBAにそれぞれのプロパティを当てはめてみる
                return half4(_Color);
            }
            ENDCG
        }
    }
}