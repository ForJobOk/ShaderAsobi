using UnityEngine;

/// <summary>
/// オブジェクトが衝突した箇所に波紋を発生させる
/// </summary>
public class CollisionRipple : MonoBehaviour
{
    [SerializeField] private CustomRenderTexture _customRenderTexture;
    [SerializeField, Range(0.01f, 0.05f)] private float _ripppleSize = 0.01f;
    [SerializeField] private int iterationPerFrame = 5;

    private CustomRenderTextureUpdateZone _defaultZone;

    private void Start()
    {
        //初期化
        _customRenderTexture.Initialize();

        //波動方程式のシミュレート用のUpdateZone
        //全体の更新用
        _defaultZone = new CustomRenderTextureUpdateZone
        {
            needSwap = true,
            passIndex = 0,
            rotation = 0f,
            updateZoneCenter = new Vector2(0.5f, 0.5f),
            updateZoneSize = new Vector2(1f, 1f)
        };
    }

    private void Update()
    {
        //クリック時のUpdateZoneがクリック後も適応された状態にならないように一度消去する
        _customRenderTexture.ClearUpdateZones();
        //更新したいフレーム数を指定して更新
        _customRenderTexture.Update(iterationPerFrame);
    }

    private void OnTriggerStay(Collider other)
    {
        Debug.Log("Enter");
        Vector3 hitPos = other.ClosestPointOnBounds(this.transform.position);
        
        //クリック時に使用するUpdateZone
        //クリックした箇所を更新の原点とする
        //使用するパスもクリック用に変更
        var clickZone = new CustomRenderTextureUpdateZone
        {
            needSwap = true,
            passIndex = 1,
            rotation = 0f,
            updateZoneCenter = new Vector2(hitPos.x, 1f - hitPos.y),
            updateZoneSize = new Vector2(_ripppleSize, _ripppleSize)
        };

        _customRenderTexture.SetUpdateZones(new CustomRenderTextureUpdateZone[] {_defaultZone, clickZone});
    }
}