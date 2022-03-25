Shader "Custom/Stencil"
{
    Properties
    {
        //メインテクスチャー
        _MainTex ("Texture", 2D) = "white" {}
        //カラー
        _TopColor("TopColor",Color) = (0,0,0,0)
        _UnderColor("UnderColor",Color) = (0,0,0,0)
        _LineColor("LineColor",Color) = (0,0,0,0)
        [HDR] _EmissionColor ("Emission Color", Color) = (0,0,0)  
        //色の境界の位置
        _ColorBorder("ColorBorder",Range(0,1)) = 0.5
        //ラインの速度
        _LineSpeed("LineSpeed",Range(0,10)) = 5
        //ラインの間隔
        _LineSpace("LineSpace",Range(0,100)) = 15
        //ラインの間隔
        _LineSize("LineSize",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Tranparent"
        }
        
        //不当明度を利用するときに必要 文字通り、1 - フラグメントシェーダーのAlpha値　という意味
        Blend SrcAlpha OneMinusSrcAlpha
        //両面描画
        Cull Off
        
        Pass
        {
  		  ZWrite ON
  		  ColorMask 0
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
                float2 scroll_uv : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 scroll_uv : TEXCOORD0;
                float2 uv : TEXCOORD1;             
            };

            sampler2D _MainTex;
            fixed4 _UnderColor;
            fixed4 _TopColor;
            fixed4 _LineColor;
            fixed4 _EmissionColor;
            fixed _ColorBorder;
            fixed _LineSpeed;
            fixed _LineSpace;
            fixed _LineSize;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.scroll_uv.y = v.scroll_uv.y - _Time.x * _LineSpeed;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //テクスチャーのサンプリング
                fixed4 tex_color = tex2D(_MainTex, i.uv);
                //グラデーション
                fixed4 gradation_color = lerp(_UnderColor, _TopColor, i.uv.y * _ColorBorder);
                //テクスチャーとグラデーションカラーからベースカラー計算
                fixed4 base_color = tex_color * gradation_color;
                //補間値
                fixed interpolation = step(frac(i.scroll_uv.y * _LineSpace), _LineSize);
                fixed3 line_color = _LineColor *_EmissionColor;
                //ベースカラーかラインカラーのどちらかを返す
                fixed4 final_color = lerp(base_color, base_color*_LineColor *_EmissionColor, interpolation);

                return final_color;
            }
            ENDCG
        }
    }
}