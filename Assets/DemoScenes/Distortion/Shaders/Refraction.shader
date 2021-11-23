Shader "Unlit/Refraction"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_BumpTex ("BumpTexture", 2D) = "white" {}
		_Distortion ("Distortion", Range(-0.3, 0.3)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}

		GrabPass{ "_GrabTex" }

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
				float4 grabPos : TEXCOORD1;
				float4 scrPos : TEXCOORD2;
			};
			sampler2D _BumpTex;
			float4 _BumpTex_ST;

			sampler2D _GrabTex;
			float4 _GrabTex_ST;
			float4 _GrabTex_TexelSize;

			sampler2D _CameraDepthTexture;
			float2 _CameraDepthTexture_ST;
			float4 _CameraDepthTexture_TexelSize;

			float4 _Color;
			float _Distortion;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _BumpTex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				o.scrPos = ComputeScreenPos(o.vertex);
				return o;
			}

			float2 AlignWithGrabTexel (float2 uv)
			{
				return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs(_CameraDepthTexture_TexelSize.xy);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 bump = UnpackNormal(tex2D(_BumpTex, i.uv));
				float4 depthUV = i.grabPos;
				depthUV.xy = i.grabPos.xy + (bump.xy * _Distortion);
				
				float surfDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.scrPos.z);
				float refFix = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(depthUV))));
				float depthDiff = saturate(refFix - surfDepth);

				float2 uvoffset = bump.xy * _Distortion * sin(i.uv.y * 50 + _Time.w) * 0.1f;
				float2 grabUV;
				grabUV = ((i.grabPos.xy + uvoffset * depthDiff) / i.grabPos.w);

				float4 col = tex2D(_GrabTex, grabUV) * _Color;
				//col = tex2D(_GrabTex, grabUV) * depthDiff * _Color;
				return col;
			}
			ENDCG
		}
	}
}