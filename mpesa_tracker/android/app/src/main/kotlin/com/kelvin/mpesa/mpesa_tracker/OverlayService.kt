package com.kelvin.mpesa.mpesa_tracker

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.IBinder
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView

class OverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private var bubbleView: android.view.View? = null

    companion object {
        const val EXTRA_AMOUNT = "amount"
        const val EXTRA_RECIPIENT = "recipient"
        const val EXTRA_DIRECTION = "direction"
        const val EXTRA_TX_CODE = "tx_code"
        const val EXTRA_BALANCE = "balance"
        const val EXTRA_TX_COST = "txCost"
        const val EXTRA_MSG_TYPE = "msgType"
        const val EXTRA_ACCOUNT_REF = "accountRef"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val amount = intent?.getDoubleExtra(EXTRA_AMOUNT, 0.0) ?: 0.0
        val recipient = intent?.getStringExtra(EXTRA_RECIPIENT) ?: ""
        val direction = intent?.getStringExtra(EXTRA_DIRECTION) ?: "out"
        val txCode = intent?.getStringExtra(EXTRA_TX_CODE) ?: ""
        val balance = intent?.getDoubleExtra(EXTRA_BALANCE, 0.0) ?: 0.0
        val txCost = intent?.getDoubleExtra(EXTRA_TX_COST, 0.0) ?: 0.0

        Log.d("OverlayService", "Showing bubble: $direction Ksh$amount")

        showBubble(amount, recipient, direction, txCode, balance, txCost)

        return START_NOT_STICKY
    }

    private fun showBubble(
        amount: Double,
        recipient: String,
        direction: String,
        txCode: String,
        balance: Double,
        txCost: Double
    ) {
        removeBubble()

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.END
            x = 24
            y = 120
        }

        bubbleView = LayoutInflater.from(this)
            .inflate(R.layout.overlay_bubble, null)

        // Format amount — strip decimals if .00
        val amountText = if (amount % 1.0 == 0.0)
            amount.toInt().toString()
        else
            "%.0f".format(amount)

        bubbleView?.findViewById<TextView>(R.id.bubble_amount)?.text = amountText

        // Set arrow direction
        val arrowText = if (direction == "in") "↓" else "↑"
        bubbleView?.findViewById<TextView>(R.id.bubble_arrow)?.text = arrowText

        // Set bubble color using the drawable so the circle shape is preserved
        val drawable = resources.getDrawable(R.drawable.bubble_background, null)
                as GradientDrawable
        val bgColor = if (direction == "in") 0xFF1A73E8.toInt() else 0xFFE53935.toInt()
        drawable.setColor(bgColor)
        bubbleView?.findViewById<LinearLayout>(R.id.bubble_collapsed)?.background = drawable

        // Drag support
        var initialX = 0; var initialY = 0
        var initialTouchX = 0f; var initialTouchY = 0f
        var isDragging = false

        bubbleView?.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x; initialY = params.y
                    initialTouchX = event.rawX; initialTouchY = event.rawY
                    isDragging = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (initialTouchX - event.rawX).toInt()
                    val dy = (event.rawY - initialTouchY).toInt()
                    if (Math.abs(dx) > 5 || Math.abs(dy) > 5) isDragging = true
                    params.x = initialX + dx
                    params.y = initialY + dy
                    windowManager.updateViewLayout(bubbleView, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (!isDragging) {
                        Log.d("OverlayService", "Bubble tapped — opening tag card overlay")
                        val intent = Intent(this@OverlayService, TagCardActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                            putExtra("amount", amount)
                            putExtra("recipient", recipient)
                            putExtra("direction", direction)
                            putExtra("txCode", txCode)
                            putExtra("balance", balance)
                            putExtra("txCost", txCost)
                            putExtra("fromBubble", true)
                        }
                        this@OverlayService.startActivity(intent)
                        removeBubble()
                        stopSelf()
                    }
                    true
                }
                else -> false
            }
        }

        windowManager.addView(bubbleView, params)
    }

    private fun removeBubble() {
        bubbleView?.let {
            try { windowManager.removeView(it) } catch (e: Exception) { }
            bubbleView = null
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        removeBubble()
        super.onDestroy()
    }
}