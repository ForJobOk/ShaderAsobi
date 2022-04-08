Shader "Custom/ColorMaskOcclusion"
{
    Properties
    {
        //ToonOutLineのパスで利用しているProperty
        _OutlineWidth ("Outline width", Range (0.005, 0.05)) = 0.01
        [HDR]_OutlineColor ("Outline Color", Color) = (0,0,0,1)
        [Toggle(USE_VERTEX_EXPANSION)] _UseVertexExpansion("Use vertex for Outline", int) = 0
    }
    
    SubShader
    {
        Tags {"Queue"="geometry-1"}
        ColorMask 0
        Pass {}
        
        //他のShaderのパスを利用
        UsePass "Custom/ToonOutLine/OUTLINE"
    }
}