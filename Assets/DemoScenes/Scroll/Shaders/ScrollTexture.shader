Shader "Custom/ScrollTexture"
{
    Properties
    {
        //スクロールさせるテクスチャ
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
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
            sampler2D _MainTex;
            half _SliceSpace;

            //GPUから頂点シェーダーに渡す構造体
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv : TEXCOORD0;
            };

            //頂点シェーダーからフラグメントシェーダーに渡す構造体
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                //UVに時間を足してく
                o.uv.y = v.uv.y + _Time.y;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                //テクスチャとUV座標から色の計算を行う
                fixed4 col = tex2D(_MainTex, i.uv); //←頂点シェーダーから渡ってきたこのUVが時間で変化する
                return half4(col);
            }
            ENDCG
        }
    }
}