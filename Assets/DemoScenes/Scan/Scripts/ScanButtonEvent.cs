using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// スキャンボタン押下時のイベント登録
/// </summary>
public class ScanButtonEvent : MonoBehaviour
{
    [SerializeField] private Button button;
    [SerializeField] private Animator animator;

    private void Start()
    {
        button.onClick.AddListener(ScanEvent);
    }

    private void OnDestroy()
    {
        button.onClick.RemoveListener(ScanEvent);
    }

    /// <summary>
    /// スキャン時のイベント
    /// アニメーターのTriggerを切り替えるだけ
    /// </summary>
    private void ScanEvent()
    {
        animator.SetTrigger("Scan");
    }
}
