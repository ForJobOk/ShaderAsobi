Shader "Custom/Glitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LineColor ("LineColor", Color) = (0,0,0,0)
        _LineSpeed("LineSpeed",Range(0,10)) = 5
        _LineSize("LineSize",Range(0,10)) = 0.01
        _ColorGap("ColorGap",Range(0,0.05)) = 0.01      
        _Alpha ("Alpha", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Tranparent" }
        Blend SrcAlpha OneMinusSrcAlpha

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
                float2 line_uv : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 line_uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _LineColor;
            float _LineSpeed;
            float _LineSize;
            float _ColorGap;
            float _Alpha;
            
            //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //UVスクロール
                o.line_uv.y = v.line_uv.y - _Time.z * _LineSpeed;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
              float2 uv = i.uv;
              float2 line_uv = i.line_uv;
              //RGBずらしてホログラムっぽく
              float r = tex2D(_MainTex, uv + _ColorGap).r;
              float b = tex2D(_MainTex, uv - _ColorGap).b;
              float2 ga = tex2D(_MainTex, uv).ga;
              float4 gap_color = fixed4(r, ga.x, b, ga.y);
              //ノイズラインの補間値計算
              float interpolation = step(frac(i.line_uv.y * 15), _LineSize);
              //ノイズラインを含むピクセルカラー
              float4 noise_line_color = lerp(gap_color,gap_color *_LineColor, interpolation);
              //グリッチのラインの補間値計算
              //どの高さに出現するかは時間変化でランダム
              float glitch = step(frac(i.line_uv.y),rand(uv.yy));
              //ノイズ計算
              uv.y = lerp(uv.y,uv.y * rand(uv.yy), glitch);
              float4 noise_color = tex2D(_MainTex,uv);
              float4 final_color = lerp(noise_line_color,noise_color, glitch);
              final_color.a = _Alpha;
              return final_color;
            }
            ENDCG
        }
    }
}
