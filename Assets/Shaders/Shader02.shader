Shader "UniteAsia/Shader02" 
{
    SubShader 
	{
		Pass
		{
			Tags { "RenderType"="Opaque" }
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #include "UnityCG.cginc"

			struct v2f 
			{
				float4 pos : SV_POSITION;
			};

            v2f vert(appdata_base v) //vはメッシュの頂点情報
			{
				v2f o;
            	//メッシュの頂点座標を時間経過に応じてSin関数で変化させている
				float4 vert = float4(v.vertex.xyz * sin(_Time.y), v.vertex.w);
                o.pos = UnityObjectToClipPos(vert);
                return o;
            }

            half4 frag(v2f i) : COLOR 
			{
				return half4(1, 1, 1, 1);
            }
			ENDCG
		}
    }
}