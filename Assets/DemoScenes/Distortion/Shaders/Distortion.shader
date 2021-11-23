Shader "Custom/Distortion"
{
    Properties
    {
        _DistortionPower("Distortion Power", Range(0, 0.1)) = 0
        [HDR]_WaterColor("WaterColor", Color) = (0,0,0,0)
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "RenderType" = "Transparent"
        }
        
        //不当明度を利用するときに必要 文字通り、1 - フラグメントシェーダーのAlpha値　という意味
        Blend SrcAlpha OneMinusSrcAlpha
        
        //1パス目
        //水面の色だけ描画
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            
            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _WaterColor;

            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _WaterColor;
            }

            ENDCG
        }
        
        //1パス目の描画結果をテクスチャーとして取得可能に
        GrabPass
        {
            "_GrabPassTextureForDistortion"
        }

        //2パス目
        //揺らぎの表現を頑張る　1パス目の描画結果を利用する
        Pass
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float4 scrPos : TEXCOORD2;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _GrabPassTextureForDistortion;
            float _DistortionPower;
            float4 _WaterColor;

            v2f vert(appdata v)
            {
                v2f o = (v2f)0;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //正しいテクスチャ座標を取得
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                //ComputeScreenPosによってxyが0〜wに変換される
                o.scrPos = ComputeScreenPos(o.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                 //Distortionの値に応じてサンプリングするUVをずらす
                float2 distortion =  sin(i.uv.y * 50 + _Time.w) * 0.1f;
                distortion *= _DistortionPower;
                float4 depthUV = i.grabPos;
				depthUV.xy = i.grabPos.xy + distortion;
               
                
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(depthUV));
                //既に描画済みのピクセルの深度情報
                float screenDepth = LinearEyeDepth(depthSample);
                //今描画しようとしているピクセルの深度情報
                float screenPosition = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.scrPos.z);

                //w除算
                float2 uv = depthUV * step(screenPosition,screenDepth) / i.grabPos.w;
                //screenDepth ≧ screenPosition のとき 0 を返す
                //step(t, x) xの値がtよりも小さい場合には0、大きい場合には1を返す
                //uv += distortion * step(screenDepth,screenPosition);
                                
                return tex2D(_GrabPassTextureForDistortion, uv);
            }
            ENDCG
        }
    }
}