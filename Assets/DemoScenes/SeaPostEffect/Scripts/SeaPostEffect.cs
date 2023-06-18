using UnityEngine;

/// <summary>
/// 自作ポストエフェクトを適用する
/// ImageEffectAllowedInSceneViewというアトリビュートを使うことでシーンビューにも反映される
/// </summary>
[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class SeaPostEffect : MonoBehaviour
{
    [SerializeField] private Material effectMaterial;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, effectMaterial);
    }
}