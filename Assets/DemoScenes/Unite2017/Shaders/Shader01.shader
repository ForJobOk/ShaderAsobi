//Shaderの名前
Shader "UniteAsia/Shader01" 
{
	//サブシェーダー　シェーダの中身を書くとこらしい　複数書けるとのこと
	//実行できない場合は最後にFallback "○○" と書いとけば○○で実行される
	SubShader 
	{
		//パス　Shader本体を書くとこらしい　複数書ける
		Pass
		{
			//タグ　透明度とか設定できるらしい
			Tags { "RenderType"="Opaque" }
		
			//こっから書きますよ　みたいな宣言
			CGPROGRAM
			//vertexシェーダーとfragmentシェーダーの関数がどれなのか伝える
			//実行モードにしなくても定義したらUnityが勝手に呼びだしてくれる
			#pragma vertex vert //vertという名前の関数がvertexシェーダーです　と宣言している　※①
			#pragma fragment frag //fragという名前の関数がfragmentシェーダーです　と宣言している　※②
			//便利関数詰め合わせセットらしい
            #include "UnityCG.cginc"

			//v2fという構造体を定義　Vertex to Fragment の略
			//文字通りvertexシェーダーとfragmentシェーダーの間におけるデータのやりとりで使う
			//vertexシェーダーの結果をfragmentシェーダーに渡す
			struct v2f 
			{
				//位置情報　"：" 以降の大文字はセマンティクスと言って必要なものだけ受け取るために用意されているらしい
				float4 pos : SV_POSITION;
			};

			//①で "これがvertexシェーダーです"　と宣言した関数
            v2f vert(appdata_base v) //頂点の情報が引数に渡ってくる
			{
            	//先ほど宣言した構造体のオブジェクトを作る
				v2f o;
            	//"3Dの世界での座標は2D(スクリーン)においてはこの位置になりますよ"　という変換を関数を使って行っている
                o.pos = UnityObjectToClipPos(v.vertex);
            	//変換した座標を返す
                return o;
            }

			//①で "これがfragmentシェーダーです"　と宣言した関数
            half4 frag(v2f i) : COLOR //頂点シェーダからの入力(input)が引数に渡ってくる　COLORは今はSV_Targetらしい
			{
				//色情報を返す　R G B A
				return half4(1, 1, 0, 1);
            }
			//ここで終わりの宣言
			ENDCG
		}
    }
}