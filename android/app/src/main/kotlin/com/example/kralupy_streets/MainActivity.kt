package com.example.kralupy_streets

import android.util.Log
import androidx.core.content.FileProvider
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val channel = "com.example.kralupy_streets/text_recognition"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            if (call.method.equals("analyzeImage")) {
                val imagePath: String = call.argument("imagePath")!!
                analyzeImage(imagePath, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun analyzeImage(imagePath: String, result: MethodChannel.Result) {
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

        try {
            val localImageFile = File(imagePath)
            val authority = "${context.packageName}.fileprovider"
            val imageUri = FileProvider.getUriForFile(context, authority, localImageFile)

            val image = InputImage.fromFilePath(context, imageUri)

            recognizer.process(image)
                .addOnSuccessListener { visionText: Text ->
                    val resultTexts = visionText.textBlocks.map { it.text }
                    Log.d("TextRecognition", "Vision text: $resultTexts")

                    // Send the result back to Flutter
                    result.success(resultTexts)
                }
                .addOnFailureListener { e: Exception ->
                    Log.d("TextRecognition", "Recognition failed: $e")
                    // Send an error message back to Flutter
                    result.error("RECOGNITION_ERROR", e.message, null)
                }
        } catch (e: IOException) {
            e.printStackTrace()
            // Send an error message back to Flutter
            result.error("IO_ERROR", e.message, null)
        }
    }
}
