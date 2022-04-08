Shader "Custom/SimplePostEffect"
{
    Properties
    {
        //_MainTexを定義しておけば勝手に描画結果が入ってくるらしい
        _MainTex ("Texture", 2D) = "white" {}
        //カラー
        _EffectColor("EffectColor",Color) = (0,0,0,0)
    }
    SubShader
    {
        //パスを跨いで利用できる変数や関数をひとまとめにしておく
        CGINCLUDE
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

        sampler2D _MainTex;

        v2f vert(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }
        ENDCG

        //色を変更するポストエフェクト
        Pass
        {
            CGPROGRAM
            float4 _EffectColor;

            float4 frag(v2f i) : SV_Target
            {
                //描画結果をサンプリング
                float4 renderingColor = tex2D(_MainTex, i.uv);
                return renderingColor * _EffectColor;
            }
            ENDCG
        }

        //モノクロになるポストエフェクト
        Pass
        {
            CGPROGRAM

            float4 frag(v2f i) : SV_Target
            {
                //描画結果をサンプリング
                float4 renderingColor = tex2D(_MainTex, i.uv);
                float monochrome = 0.3 * renderingColor.r + 0.6 * renderingColor.g + 0.1 * renderingColor.b;
                float4 monochromeColor = float4(monochrome.xxx, 1);
                return monochromeColor;
            }
            ENDCG
        }
    }
}