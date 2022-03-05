Shader "Custom/SpriteAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //セルの列数
        _Column ("Column", int) = 8
        //セルの行数
		_Row ("Row", int) = 8
        //アニメーションの速度
		_Fps ("FPS", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Trasparent" }
        
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
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			uint _Row;
			uint _Column;
			uint _Fps;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 col_row = float2(_Column,_Row);
            	//UVを各方向のセル数で割る　ここでUVが変化し左下のセルが表示された状態になる
				i.uv /= col_row;
                //経過時間/セルの総数で剰余を算出する 剰余がそのままインデックスになる
                // 例) (FPS1 * 8秒経過) % 総セル数10　= インデックス8
                //　   (FPS1 * 9秒経過) % 総セル数10　= インデックス9
                //　   (FPS1 * 10秒経過) % 総セル数10　= インデックス0
                //　   (FPS1 * 11秒経過) % 総セル数10　= インデックス1
				uint index = uint(_Fps * _Time.y) % (_Column * _Row);
                //列のインデックスを計算
                uint column_index = index % _Column;
                //行のインデックスを計算
                uint row_index = _Row - (index /_Column)  % _Row - 1;
                //インデックスをUV値に反映
				i.uv += float2(column_index, row_index) / col_row;
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
