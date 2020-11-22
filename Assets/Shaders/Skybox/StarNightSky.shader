Shader "Custom/StarNightSky"
{
    Properties
    {
        _BaseColor("BaseColor",Color) = (0,0,0,0)
        _StarColor("StartColor",Color) = (0,0,0,0)
        _SquareNum ("SquareNum", int) = 10

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
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)), dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            int _SquareNum;
            float4 _StarColor;
            float4 _BaseColor;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 st = i.uv;
                st *= _SquareNum;
                float4 c;

                float2 ist = floor(st); //整数
               
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 neighbor = float2(x, y);
                        float2 p = 0.5 + 0.5 * random2(ist + neighbor);

                        if(distance(i.uv,p)<0.1)
                        {
                            c = _StarColor;
                        }
                        else
                        {
                            c = _BaseColor;
                        }
                    }
                }

                return c;
            }
            ENDCG
        }
    }
}