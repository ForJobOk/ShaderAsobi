Shader "Custom/2DWave"
{
    Properties
    {
        //メインテクスチャー
        _MainTex ("Texture", 2D) = "white" {}
        //カラー
        _TopColor("TopColor",Color) = (0,0,0,0)
        _UnderColor("UnderColor",Color) = (0,0,0,0)
        _LineColor("LineColor",Color) = (0,0,0,0)
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            fixed4 _UnderColor;
            fixed4 _TopColor;
            fixed4 _LineColor;
            float _ColorBorder;
            float _LineSpeed;
            float _LineSpace;
            float _LineSize;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.y = v.uv.y - _Time.x * _LineSpeed;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 base_color = tex2D(_MainTex, i.uv);
                fixed4 main_color = lerp(_UnderColor, _TopColor, frac(i.uv.y) * _ColorBorder);       
                fixed4 color = base_color + main_color;
                fixed interpolation = step(frac(i.uv.y * _LineSpace), _LineSize);
                //Color1かColor2のどちらかを返す
                fixed4 final_color = lerp(color,_LineColor, interpolation);

                return final_color;
            }
            ENDCG
        }
    }
}