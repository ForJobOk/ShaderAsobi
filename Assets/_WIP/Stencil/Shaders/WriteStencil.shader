Shader "Custom/WriteStencil"
{
    Properties
    {
        _Ref("Ref", Int) = 1
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType" = "Opaque"
                "Queue" = "Geometry-1"
            }

            //カラーチャンネルに書き込むレンダーターゲットを設定する
            //0の場合、全てのカラーチャンネルが無効化され何も書き込まれない
            ColorMask 0
            ZWrite Off
            //ステンシルバッファに関して
            Stencil
            {
                //ステンシルの値
                Ref [_Ref]

                //ステンシルバッファの値の判定方法
                //Alwaysなのでステンシルバッファのテストは常に通過する
                Comp Always

                //ステンシルバッファに値を書き込むかどうか
                //Replaceなので既存の値をRefの値に置き換える
                Pass Replace
            }
        }
    }
}