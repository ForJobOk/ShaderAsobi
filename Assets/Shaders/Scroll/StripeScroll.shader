Shader "Custom/StripeScroll"
{
    Properties
    {
        //色
        _StripeColor1("StripeColor1",Color) = (1,0,0,0)
        _StripeColor2("StripeColor2",Color) = (0,1,0,0)
        //スライスされる間隔
        _SliceSpace("SliceSpace",Range(0,1)) = 0.5
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
            half4 _StripeColor1;
            half4 _StripeColor2;
            half _SliceSpace;

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                //UVスクロール
                o.uv = v.uv + _Time.x * 2;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                //補間値の計算　と言っても0か1しか返ってこない
                //step関数：step(t, x)
                //xの値がtよりも小さい場合には0、大きい場合には1を返す
                half interpolation = step(frac(i.uv.y * 15), _SliceSpace);
                //Color1かColor2のどちらかを返す
                half4 color = lerp(_StripeColor1,_StripeColor2, interpolation);
                //計算し終わったピクセルの色を返す
                return color;
            }
            ENDCG
        }
    }
}