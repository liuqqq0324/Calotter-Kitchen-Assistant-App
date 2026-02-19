package com.example.personal_sous_chef

import android.app.Application
import android.util.Log
import android.os.Build

class MainApplication : Application() {
    companion object {
        private const val TAG = "MainApplication"
        private var librariesLoaded = false
        
        init {
            loadLibraries()
        }
        
        @Synchronized
        fun loadLibraries() {
            if (librariesLoaded) {
                Log.d(TAG, "[Application] 库已经加载，跳过")
                return
            }
            
            Log.d(TAG, "========== 开始加载 Native 库 ==========")
            Log.d(TAG, "设备架构: ${Build.SUPPORTED_ABIS.contentToString()}")
            
            // 先加载 onnxruntime
            var onnxRuntimeLoaded = false
            try {
                Log.d(TAG, "[1/2] 尝试加载 libonnxruntime.so...")
                System.loadLibrary("onnxruntime")
                Log.d(TAG, "✅ [1/2] libonnxruntime.so 加载成功")
                onnxRuntimeLoaded = true
            } catch (e: UnsatisfiedLinkError) {
                val msg = e.message ?: ""
                if (msg.contains("already loaded", ignoreCase = true) ||
                    msg.contains("Library already loaded", ignoreCase = true)) {
                    Log.d(TAG, "ℹ️ [1/2] libonnxruntime.so 已加载")
                    onnxRuntimeLoaded = true
                } else {
                    Log.e(TAG, "❌ [1/2] libonnxruntime.so 加载失败")
                    Log.e(TAG, "错误信息: $msg")
                    Log.e(TAG, "异常堆栈:\n${e.stackTraceToString()}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "❌ [1/2] libonnxruntime.so 加载异常: ${e.message}")
                Log.e(TAG, "异常类型: ${e.javaClass.name}")
            }
            
            // 等待一下，确保符号表更新
            if (onnxRuntimeLoaded) {
                try {
                    Thread.sleep(200) // 增加延迟
                    Log.d(TAG, "等待 200ms 后继续...")
                } catch (e: InterruptedException) {
                    Thread.currentThread().interrupt()
                }
            }
            
            // 再加载 sherpa-onnx-c-api
            try {
                Log.d(TAG, "[2/2] 尝试加载 libsherpa-onnx-c-api.so...")
                System.loadLibrary("sherpa-onnx-c-api")
                Log.d(TAG, "✅ [2/2] libsherpa-onnx-c-api.so 加载成功")
                librariesLoaded = true
            } catch (e: UnsatisfiedLinkError) {
                val msg = e.message ?: ""
                if (msg.contains("already loaded", ignoreCase = true) ||
                    msg.contains("Library already loaded", ignoreCase = true)) {
                    Log.d(TAG, "ℹ️ [2/2] libsherpa-onnx-c-api.so 已加载")
                    librariesLoaded = true
                } else {
                    Log.e(TAG, "❌ [2/2] libsherpa-onnx-c-api.so 加载失败")
                    Log.e(TAG, "错误信息: $msg")
                    Log.e(TAG, "异常堆栈:\n${e.stackTraceToString()}")
                    
                    // 如果是找不到符号的错误，特别记录
                    if (msg.contains("cannot locate symbol", ignoreCase = true) ||
                        msg.contains("OrtGetApiBase", ignoreCase = true)) {
                        Log.e(TAG, "⚠️⚠️⚠️ 关键错误: 找不到 OrtGetApiBase 符号!")
                        Log.e(TAG, "这可能是由于:")
                        Log.e(TAG, "  1. libonnxruntime.so 未正确加载")
                        Log.e(TAG, "  2. 库版本不兼容")
                        Log.e(TAG, "  3. 符号可见性问题")
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "❌ [2/2] libsherpa-onnx-c-api.so 加载异常: ${e.message}")
                Log.e(TAG, "异常类型: ${e.javaClass.name}")
            }
            
            Log.d(TAG, "========== Native 库加载完成 ==========")
        }
    }
    
    override fun onCreate() {
        Log.d(TAG, "========== [Application] onCreate() 开始 ==========")
        super.onCreate()
        
        // 再次确保库已加载
        loadLibraries()
        
        Log.d(TAG, "========== [Application] onCreate() 完成 ==========")
    }
}

