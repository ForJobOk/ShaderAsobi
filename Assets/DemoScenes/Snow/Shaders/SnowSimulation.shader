Shader "Custom/SnowSimulation"
{
    Properties
    {
        _InteractiveDisplacement("Interactive Displacement", Range(-1.0, 1.0)) = 0.1
    }

    CGINCLUDE
    #include "UnityCustomRenderTexture.cginc"

    float _InteractiveDisplacement;

    //通常状態
    float4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;
        // 現在の位置のテクセルをフェッチ
        float2 self = tex2D(_SelfTexture2D, uv);
        
        // 現在の状態をテクスチャのR成分に、ひとつ前の（過去の）状態をG成分に書き込む。
        return float4(self.r * 0.99, 0, 0, 0);
    }

    //インタラクティブに応じて利用されるフラグメントシェーダー
    float4 frag_interactive(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;
        // 現在の位置のテクセルをフェッチ
        float2 self = tex2D(_SelfTexture2D, uv);
        
        return float4(clamp((self.r - 0.01) * 1.0001,_InteractiveDisplacement,0), 0, 0, 0);
    }
    
    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        //デフォルトで利用されるPass
        Pass
        {
            Name "Update"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            ENDCG
        }

        //インタラクティブに応じて利用されるPass
        Pass
        {
            Name "Interactive"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag_interactive
            ENDCG
        }
    }
}