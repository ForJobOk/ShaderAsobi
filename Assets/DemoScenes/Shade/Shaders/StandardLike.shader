Shader "Custom/StandardLike"
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
    }

    SubShader
    {
        //StandardShaderのパスを利用
        //フォワードレンダリングの色々
        UsePass "Standard/FORWARD"

        //StandardShaderのパスを利用
        //影を落とす処理
        UsePass "Standard/ShadowCaster"
    }
}