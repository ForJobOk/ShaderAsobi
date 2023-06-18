Shader "Custom/SeaPostEffect"
{
    Properties
    {
        //_MainTexを定義しておけば勝手に描画結果が入ってくるらしい
        _MainTex ("Texture", 2D) = "white" {}
        //カラー
        _EffectColor("EffectColor",Color) = (0,0,0,0)
        //歪みの値
        _DistortionPower("Distortion Power", Range(0, 0.1)) = 0
    }
    SubShader
    {
        Pass
        {

            //パスを跨いで利用できる変数や関数をひとまとめにしておく
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

            sampler2D _MainTex;
            float _DistortionPower;
            float4 _EffectColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                //サンプリングするUVをずらす sin波でゆらゆら
                float2 distortion = sin(i.uv.y * 50 + _Time.w) * 0.1f;
                distortion *= _DistortionPower;
                //描画結果をサンプリング
                float4 renderingColor = tex2D(_MainTex, i.uv + distortion);
                return renderingColor * _EffectColor;
            }
            ENDCG
        }
    }
}