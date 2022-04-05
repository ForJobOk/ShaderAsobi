Shader "Custom/StandardLikeOutLine"
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
        
        //ToonOutLineのパスで利用しているProperty
        _OutlineWidth ("Outline width", Range (0.005, 0.05)) = 0.01
        [HDR]_OutlineColor ("Outline Color", Color) = (0,0,0,1)
        [Toggle(USE_VERTEX_EXPANSION)] _UseVertexExpansion("Use vertex for Outline", int) = 0

    }

    SubShader
    {
        //StandardShaderのパスを利用
        //フォワードレンダリングの色々
        UsePass "Standard/FORWARD"
        
        //StandardShaderのパスを利用
        //影を落とす処理
        UsePass "Standard/ShadowCaster"
      
         //他のShaderのパスを利用
        UsePass "Custom/ToonOutLine/OUTLINE"
    }
}