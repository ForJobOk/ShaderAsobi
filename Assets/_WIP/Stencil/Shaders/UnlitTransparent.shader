  
Shader "Custom/UnlitTransparent" 
{
	Properties
	{
		//ここに書いたものがInspectorに表示される
		 _MainTex ("Texture", 2D) = "white" {}
	}

    SubShader 
	{
		Cull off
		
		Pass
		{
			Tags { "RenderType"="Tranparent" }
			//不当明度を利用するときに必要 文字通り、1 - フラグメントシェーダーのAlpha値　という意味
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #include "UnityCG.cginc"

			sampler2D _MainTex;

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

            v2f vert(appdata_base v) 
			{
				v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
            	o.texcoord = v.texcoord;
                return o;
            }

            float4 frag(v2f i) : COLOR 
			{
				float4 col = tex2D(_MainTex, i.texcoord);
				return col;
            }
			ENDCG
		}
    }
}