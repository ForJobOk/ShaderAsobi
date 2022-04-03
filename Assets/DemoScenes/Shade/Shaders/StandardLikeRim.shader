Shader "Custom/StandardLikeRim"
{
    Properties
    {
        //StandardShaderのパス内で利用しているProperty
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5

        //Rimのパス内で利用しているProperty
        _RimColor("Rim Color", Color) = (0,1,1,1)
        _RimPower("Rim Power", Range(0,1)) = 0.4
    }

    SubShader
    {
        //StandardShaderのパスを利用
        //フォワードレンダリングの色々
        UsePass "Standard/FORWARD"

        //StandardShaderのパスを利用
        //影を落とす処理
        UsePass "Standard/ShadowCaster"

        //Rimのパスを利用
        //リムライト処理
        UsePass "Custom/Rim/RIM"
    }
}