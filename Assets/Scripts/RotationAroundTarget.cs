using UnityEngine;

/// <summary>
/// 特定のオブジェクトを中心にカメラが回転
/// カメラにアタッチ
/// </summary>
public class RotationAroundTarget : MonoBehaviour
{
    [SerializeField] private Transform _targetTransfrom;
    [SerializeField] private float _speed = 0.5f;
    [SerializeField] private float _radius = 10.0f;
    [SerializeField] private float _upper = 1.0f;

    void Update()
    {
        float posX = _radius * Mathf.Sin(Time.time * _speed);
        float posZ = _radius * Mathf.Cos(Time.time * _speed);

        transform.position = new Vector3(posX, _upper, posZ);
        transform.LookAt(_targetTransfrom);
    }
}