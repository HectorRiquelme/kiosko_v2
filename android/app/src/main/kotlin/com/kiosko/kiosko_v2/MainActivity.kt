package com.kiosko.kiosko_v2

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.kiosko.transbank"
    private val TRANSBANK_REQUEST_CODE = 1001
    private val TRANSBANK_PACKAGE = "cl.transbank.pos"

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "processPayment" -> {
                    val amount = call.argument<Int>("amount") ?: 0
                    val orderId = call.argument<String>("orderId") ?: ""
                    processTransbankPayment(amount, orderId, result)
                }
                "isAvailable" -> {
                    result.success(isTransbankInstalled())
                }
                "getLastTransaction" -> {
                    // Last transaction query via Transbank intent
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isTransbankInstalled(): Boolean {
        return try {
            packageManager.getPackageInfo(TRANSBANK_PACKAGE, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun processTransbankPayment(amount: Int, orderId: String, result: MethodChannel.Result) {
        pendingResult = result

        try {
            val intent = Intent("cl.transbank.pos.ACTION_SALE").apply {
                putExtra("amount", amount)
                putExtra("externalId", orderId)
                putExtra("printOnPos", true)
            }

            if (intent.resolveActivity(packageManager) != null) {
                startActivityForResult(intent, TRANSBANK_REQUEST_CODE)
            } else {
                pendingResult = null
                result.error("NOT_AVAILABLE", "Transbank POS app no encontrada", null)
            }
        } catch (e: Exception) {
            pendingResult = null
            result.error("ERROR", e.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == TRANSBANK_REQUEST_CODE) {
            val result = pendingResult
            pendingResult = null

            if (result == null) return

            if (resultCode == Activity.RESULT_CANCELED) {
                result.error("CANCELLED", "Pago cancelado", null)
                return
            }

            val responseMap = HashMap<String, Any?>()
            data?.let {
                responseMap["responseCode"] = it.getIntExtra("responseCode", -1)
                responseMap["authorizationCode"] = it.getStringExtra("authorizationCode")
                responseMap["transactionId"] = it.getStringExtra("transactionId")
                responseMap["amount"] = it.getIntExtra("amount", 0)
                responseMap["cardLast4"] = it.getStringExtra("cardNumber")?.takeLast(4)
                responseMap["message"] = it.getStringExtra("responseMessage")
                responseMap["voucherText"] = it.getStringExtra("voucherText")
            }

            result.success(responseMap)
        }
    }
}
