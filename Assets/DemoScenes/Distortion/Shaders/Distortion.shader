Shader "Custom/Distortion"
{
    Properties
    {
        _DistortionPower("Distortion Power", Range(0, 0.1)) = 0
        _WaterColor("WaterColor", Color) = (0,0,0,0)
        _DepthFactor("Depth Factor", float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "RenderType" = "Transparent"
        }
        
        //不当明度を利用するときに必要 文字通り、1 - フラグメントシェーダーのAlpha値　という意味
        Blend SrcAlpha OneMinusSrcAlpha
        
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
            };

            half4 _WaterColor;

            v2f vert(appdata v)
            {
                v2f o = (v2f)0;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _WaterColor;
            }

            ENDCG
        }
        
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
                float4 scrPos : TEXCOORD2;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _GrabPassTexture;
            half _DistortionPower;
            half4 _WaterColor;
            float _DepthFactor;

            v2f vert(appdata v)
            {
                v2f o = (v2f)0;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                //ComputeScreenPosによってxyが0〜wに変換される
                o.scrPos = ComputeScreenPos(o.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos));
                //平面の深度情報
                float surfDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.scrPos.z);
                //スクリーンに描画されるピクセルの深度情報
                half screenDepth = LinearEyeDepth(depthSample) - i.scrPos.w;
               
                //w除算
                half2 uv = i.grabPos.xy / i.grabPos.w;

                //Distortionの値に応じてサンプリングするUVをずらす
                half2 distortion =  sin(i.uv.y * 50 + _Time.w) * 0.1f;
                distortion *= _DistortionPower;

                //screenDepth ≧ surfDepth のとき 0 を返す
                uv += distortion * step(screenDepth,surfDepth);
                                
                float edge = 1 - saturate(_DepthFactor * screenDepth);
                return lerp(_WaterColor, tex2D(_GrabPassTexture, uv), edge);
            }
            ENDCG
        }
    }
}