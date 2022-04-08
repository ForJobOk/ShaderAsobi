using UnityEngine;

/// <summary>
/// 自作ポストエフェクトを適用する
/// ImageEffectAllowedInSceneViewというアトリビュートを使うことでシーンビューにも反映される
/// </summary>
[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CustomColorPostEffect : MonoBehaviour
{
    [SerializeField] private Material colorEffectMaterial;
    
    private enum UsePass
    {
        UsePass1,
        UsePass2
    }

    [SerializeField] private UsePass usePass;
    
    
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, colorEffectMaterial,(int)usePass);
    }
}