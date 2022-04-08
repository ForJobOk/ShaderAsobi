using UnityEngine;

/// <summary>
/// 影の描画距離をShaderのグローバル変数で設定する
/// </summary>
[ExecuteAlways]
public class SetShadowDistance : MonoBehaviour
{
    private void Start()
    {
        Shader.SetGlobalFloat("_ShadowDistance",QualitySettings.shadowDistance); 
    }

    void Update()
    {
        //Editor上だけ設定値をリアルタイムに反映する
        if(!Application.isEditor) return;
        Shader.SetGlobalFloat("_ShadowDistance",QualitySettings.shadowDistance); 
    }
}
