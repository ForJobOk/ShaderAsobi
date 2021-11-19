Shader "Custom/Distortion"
{
    Properties
    {
        _DistortionTex("Distortion Texture(RG)", 2D) = "grey" {}
        _DistortionPower("Distortion Power", Range(0, 1)) = 0
        _Color("WaterColor", Color) = (0,0,0,0)
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "RenderType" = "Transparent"
        }
        

        ZWrite Off

        GrabPass
        {
            "_GrabPassTexture"
        }

        Pass
        {
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                half4 vertex : POSITION;
                half4 uv : TEXCOORD0;
            };

            struct v2f
            {
                half4 vertex : SV_POSITION;
                half2 uv : TEXCOORD0;
                half4 grabPos : TEXCOORD1;
            };

            sampler2D _DistortionTex;
            sampler2D _GrabPassTexture;
            half _DistortionPower;
            half4 _Color;

            v2f vert(appdata v)
            {
                v2f o = (v2f)0;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabPos = ComputeGrabScreenPos(o.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                // w除算
                half2 uv = half2(i.grabPos.x / i.grabPos.w, i.grabPos.y / i.grabPos.w);

                // Distortionの値に応じてサンプリングするUVをずらす
                half2 distortion = UnpackNormal(tex2D(_DistortionTex, i.uv + _Time.x * 0.1f)).rg;
                distortion *= _DistortionPower;

                uv += distortion;
                return tex2D(_GrabPassTexture, uv) * _Color;
            }
            ENDCG
        }
    }
}