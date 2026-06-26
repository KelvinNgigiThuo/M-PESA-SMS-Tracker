package com.kelvin.mpesa.mpesa_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        // Extract SMS data immediately on main thread — this is fast
        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        val fullBody = messages.joinToString("") { it.messageBody ?: "" }
        val sender = messages.firstOrNull()?.originatingAddress ?: ""

        Log.d("SmsReceiver", "SMS from: $sender")
        Log.d("SmsReceiver", "Body: $fullBody")

        // Hand everything else to a background thread immediately
        // pendingResult keeps the receiver alive until background work finishes
        val pendingResult = goAsync()

        CoroutineScope(Dispatchers.IO).launch {
            try {
                when {
                    MpesaParser.isOutgoing(sender, fullBody) -> {
                        val parsed = MpesaParser.parse(fullBody, "out")
                        Log.d("SmsReceiver", "OUTGOING — Ksh${parsed.amount} to ${parsed.recipient}")
                        triggerBubble(context, parsed)
                    }
                    MpesaParser.isIncoming(sender, fullBody) -> {
                        val parsed = MpesaParser.parse(fullBody, "in")
                        Log.d("SmsReceiver", "INCOMING — Ksh${parsed.amount} from ${parsed.recipient}")
                        triggerBubble(context, parsed)
                    }
                    else -> {
                        Log.d("SmsReceiver", "Not an M-Pesa transaction SMS — ignored")
                    }
                }
            } finally {
                // Always release the pending result when done
                pendingResult.finish()
            }
        }
    }

    private fun triggerBubble(context: Context, parsed: MpesaMessage) {
    val intent = Intent(context, OverlayService::class.java).apply {
        putExtra(OverlayService.EXTRA_AMOUNT, parsed.amount)
        putExtra(OverlayService.EXTRA_RECIPIENT, parsed.recipient)
        putExtra(OverlayService.EXTRA_DIRECTION, parsed.direction)
        putExtra(OverlayService.EXTRA_TX_CODE, parsed.transactionCode)
        putExtra(OverlayService.EXTRA_BALANCE, parsed.balanceAfter)
        putExtra(OverlayService.EXTRA_TX_COST, parsed.transactionCost)
        putExtra(OverlayService.EXTRA_MSG_TYPE, parsed.messageType)
        putExtra(OverlayService.EXTRA_ACCOUNT_REF, parsed.accountReference)
    }
    context.startService(intent)
}
}