Shader "Custom/Hole"
{
    //Inspectorに出すプロパティー
    Properties
    {
        _ClipSize("ClipSize", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "Queue"="geometry-1"
        }

        Blend Zero SrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            float _ClipSize;

            float circle(float2 p, float radius)
            {
                return length(p) - radius;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 f_st = frac(i.uv) * 2 - 1;
                float ci = circle(f_st, 0);
                float4 col = step(_ClipSize,ci);
                
                //引数の値が"0以下なら"描画しない　すなわち"Alphaが0.5以下なら"描画しない
                clip(col.a - 0.5);
                return col;
            }
            ENDCG
        }
    }
}