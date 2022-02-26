Shader "Custom/MatrixScale"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _ScaleX("ScaleX",Range(0,2)) = 1
        _ScaleY("ScaleY",Range(0,2)) = 1
        _ScaleZ("ScaleZ",Range(0,2)) = 1
    }
    SubShader
    {
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

            sampler2D _MainTex;
            float _ScaleX;
            float _ScaleY;
            float _ScaleZ;

            v2f vert(appdata v)
            {
                v2f o;
                //スケールのための行列を計算
                half4x4 scaleMatrix = half4x4(_ScaleX, 0, 0, 0,
                                             0, _ScaleY, 0, 0,
                                             0, 0, _ScaleZ, 0,
                                             0, 0, 0, 1);
                v.vertex = mul(scaleMatrix, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //テクスチャーのサンプリング
                fixed4 tex_color = tex2D(_MainTex, i.uv);
                return tex_color;
            }
            ENDCG
        }
    }
}