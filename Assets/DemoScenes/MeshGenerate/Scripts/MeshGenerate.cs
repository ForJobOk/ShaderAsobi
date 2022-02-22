using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// メッシュをランタイムで生成する
/// </summary>
[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class MeshGenerate : MonoBehaviour
{
    private void Start()
    {
        FourSidedPyramid();
    }
    
    /// <summary>
    /// 四角錐を生成
    /// </summary>
    private void FourSidedPyramid()
    {
        //四角錐の頂点を作成する
        //シンプルだからまだいいけど、本来は図解しないとキツイ
        var vertices = new List<Vector3>() {
            // 0,1,2,3
            new Vector3(0f, 0f, 0f),
            new Vector3(1f, 0f, 0f),
            new Vector3(1f, 0f, 1f),
            new Vector3(0f, 0f, 1f),
            // 4,5,6
            new Vector3(0f, 0f, 0f),
            new Vector3(0.5f, 1f, 0.5f),
            new Vector3(1f, 0f, 0f),
            // 7,8,9
            new Vector3(1f, 0f, 0f),
            new Vector3(0.5f, 1f, 0.5f),
            new Vector3(1f, 0f, 1f),
            // 10,11,12
            new Vector3(1f, 0f, 1f),
            new Vector3(0.5f, 1f, 0.5f),
            new Vector3(0f, 0f, 1f),
            // 13,14,15
            new Vector3(0f, 0f, 1f),
            new Vector3(0.5f, 1f, 0.5f),
            new Vector3(0f, 0f, 0f),
        };

        //頂点のインデックスを整える
        //この順番を参照して面ができあがる
        var triangles = new List<int>
        {
            //底面
            3, 0, 1, 3, 1, 2,
            //側面
            4, 5, 6,
            7, 8, 9,
            10, 11, 12,
            13, 14, 15,
        };

        //メッシュを作成
        var mesh = new Mesh();
        //初期化
        mesh.Clear();
        
        
        //メッシュに頂点を登録
        mesh.SetVertices(vertices);
        //メッシュにインデックスリストを登録する　第二引数はサブメッシュ(複数マテリアル割り当てる場合に使われるメッシュ)指定用
        mesh.SetTriangles(triangles, 0);
        //各頂点に色の情報を付与
        mesh.colors = new []  
        {
            Color.red,      
            Color.green,    
            Color.blue,     
            Color.gray,     
            Color.red,      
            Color.green,    
            Color.blue,     
            Color.gray,     
            Color.red,      
            Color.green,    
            Color.blue,     
            Color.gray,
            Color.red,      
            Color.green,    
            Color.blue,
            Color.gray
        };
        //法線の再計算
        mesh.RecalculateNormals();
        // 作成したメッシュを適応
        var meshFilter = GetComponent<MeshFilter>();
        meshFilter.mesh = mesh;
    }
}