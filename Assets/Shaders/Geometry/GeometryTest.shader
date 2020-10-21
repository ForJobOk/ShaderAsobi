Shader "Custom/GeometryTest"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_ScaleFactor ("Scale Factor", float) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			fixed4 _Color;
			float _ScaleFactor;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct g2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			appdata vert (appdata v)
			{
				return v;
			}

			// ジオメトリシェーダー
			[maxvertexcount(3)]
			void geom (triangle appdata input[3], inout TriangleStream<g2f> stream)
			{
				// 法線を計算
				float3 vec1 = input[1].vertex - input[0].vertex;
				float3 vec2 = input[2].vertex - input[0].vertex;
				float3 normal = normalize(cross(vec1, vec2));

				[unroll]
				for(int i = 0; i < 3; i++)
				{
					appdata v = input[i];
					g2f o;
					// 法線ベクトルに沿って頂点を移動
					v.vertex.xyz += normal * (_SinTime.w * 0.5 + 0.5) * _ScaleFactor; 
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					stream.Append(o);
				}
				stream.RestartStrip();
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				fixed4 col = _Color;
				return col;
			}
			ENDCG
		}
	}
}