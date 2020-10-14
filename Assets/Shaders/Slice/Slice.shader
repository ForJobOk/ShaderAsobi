Shader "Custom/Slice"
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
                "RenderType"="Tranparent"
            }
            
            //不当明度を利用するときに必要 文字通り、1 - フラグメントシェーダーのAlpha値　という意味
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            //変数の宣言　Propertiesで定義した名前と一致させる
            half4 _Color;
            half _SliceSpace;

            struct v2f
            {
                float4 pos : SV_POSITION; //こいつ(pos)には座標変換された後の頂点座標をいれるぜ！ってGPUに教える
                float3 worldPos : WORLD_POS; //こいつ(worldPos)にはワールド座標をいれるぜ！ってGPUに教える
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                //unity_ObjectToWorld × 頂点座標(v.vertex) = 描画しようとしてるピクセルのワールド座標　らしい
                //mulは行列の掛け算をやってくれる関数
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                //各ピクセルのワールド座標(Y軸)それぞれに15をかけてfrac関数で少数だけ取り出す
                //そこから-0.5してclip関数で0を下回ったら描画しない
                clip(frac(i.worldPos.y * _SliceSpace) - 0.5);
                //RGBAにそれぞれのプロパティを当てはめてみる
                return half4(_Color);
            }
            ENDCG
        }
    }
}