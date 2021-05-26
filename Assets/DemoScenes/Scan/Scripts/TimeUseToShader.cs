using UnityEngine;

/// <summary>
/// アニメーションで変化させた値をShaderで使ってみる
/// </summary>
[ExecuteAlways] //こいつ付けとけばEditorでプレビュー可能
public class TimeUseToShader : MonoBehaviour
{
    // シェーダーで利用する値たち　C#側ではAnimatorで変化させる
    public float TimeValue;

    private Vector3 cameraDirection;

    /// <summary>
    /// ジオメトリシェーダーを適用したオブジェクトのレンダラー
    /// </summary>
    [SerializeField] private Material mat;
    
    // Shader側に用意した定義済みの値を受け取る変数たち
    private string _timeFactor = "_TimeFactor";

    void Update()
    {
       
        //Shaderに値を渡す
        mat?.SetFloat(_timeFactor, TimeValue);
    }
}