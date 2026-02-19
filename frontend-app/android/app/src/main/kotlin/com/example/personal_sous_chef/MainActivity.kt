package com.example.personal_sous_chef

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        
        init {
            // 静态初始化块中预先加载库（更早执行）
            // 必须在任何代码使用这些库之前加载
            try {
                System.loadLibrary("onnxruntime")
                Log.d(TAG, "✅ 成功预加载 libonnxruntime.so (静态初始化)")
            } catch (e: UnsatisfiedLinkError) {
                Log.e(TAG, "⚠️ 静态预加载 libonnxruntime.so 失败: ${e.message}")
            }
            
            try {
                System.loadLibrary("sherpa-onnx-c-api")
                Log.d(TAG, "✅ 成功预加载 libsherpa-onnx-c-api.so (静态初始化)")
            } catch (e: UnsatisfiedLinkError) {
                Log.e(TAG, "⚠️ 静态预加载 libsherpa-onnx-c-api.so 失败: ${e.message}")
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        // 在 Flutter 引擎初始化之前再次尝试预加载（作为备用）
        // 即使静态初始化失败，这里也会尝试加载
        try {
            System.loadLibrary("onnxruntime")
            Log.d(TAG, "✅ 成功预加载 libonnxruntime.so (onCreate)")
        } catch (e: UnsatisfiedLinkError) {
            // 如果已经加载过，会抛出这个异常，这是正常的
            if (e.message?.contains("already loaded") == true) {
                Log.d(TAG, "ℹ️ libonnxruntime.so 已加载 (onCreate)")
            } else {
                Log.e(TAG, "⚠️ onCreate 预加载 libonnxruntime.so 失败: ${e.message}")
            }
        }
        
        try {
            System.loadLibrary("sherpa-onnx-c-api")
            Log.d(TAG, "✅ 成功预加载 libsherpa-onnx-c-api.so (onCreate)")
        } catch (e: UnsatisfiedLinkError) {
            // 如果已经加载过，会抛出这个异常，这是正常的
            if (e.message?.contains("already loaded") == true) {
                Log.d(TAG, "ℹ️ libsherpa-onnx-c-api.so 已加载 (onCreate)")
            } else {
                Log.e(TAG, "⚠️ onCreate 预加载 libsherpa-onnx-c-api.so 失败: ${e.message}")
            }
        }
        
        super.onCreate(savedInstanceState)
    }
}
