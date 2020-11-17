using UnityEngine;

/// <summary>
/// アニメーションで変化させた値をShaderで使ってみる
/// </summary>
[ExecuteAlways] //こいつ付けとけばEditorでプレビュー可能
public class AnimationUseToShader : MonoBehaviour
{
    // シェーダーで利用する値たち　C#側ではAnimatorで変化させる
    public float gravityValue;
    public float positionValue;
    public float rotationValue;
    public float scaleValue;
    
    /// <summary>
    /// ジオメトリシェーダーを適用したオブジェクトのレンダラー
    /// </summary>
    [SerializeField] private Renderer _renderer;
    
    // Shader側に用意した定義済みの値を受け取る変数たち
    private string _gravityFactor = "_GravityFactor";
    private string _positionFactor = "_PositionFactor";
    private string _rotationFactor = "_RotationFactor";
    private string _scaleFactor = "_ScaleFactor";
    
    private Material mat;

    void Start ()
    {
        mat = _renderer.material;
    }
    
    void Update()
    {
        //Shaderに値を渡す
        mat.SetFloat(_gravityFactor, gravityValue);
        mat.SetFloat(_positionFactor, positionValue);
        mat.SetFloat(_rotationFactor, rotationValue);
        mat.SetFloat(_scaleFactor, scaleValue);
    }
}
