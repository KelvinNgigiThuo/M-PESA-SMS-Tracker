package com.kelvin.mpesa.mpesa_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        val fullBody = messages.joinToString("") { it.messageBody ?: "" }
        val sender = messages.firstOrNull()?.originatingAddress ?: ""

        Log.d("SmsReceiver", "SMS from: $sender")
        Log.d("SmsReceiver", "Body: $fullBody")

        when {
            MpesaParser.isOutgoing(sender, fullBody) -> {
                val parsed = MpesaParser.parse(fullBody, "out")
                Log.d("SmsReceiver", "OUTGOING — Ksh${parsed.amount} to ${parsed.recipient}")
                // M3: trigger bubble here
            }
            MpesaParser.isIncoming(sender, fullBody) -> {
                val parsed = MpesaParser.parse(fullBody, "in")
                Log.d("SmsReceiver", "INCOMING — Ksh${parsed.amount} from ${parsed.recipient}")
                // M3: trigger bubble here
            }
            else -> {
                Log.d("SmsReceiver", "Not an M-Pesa transaction SMS — ignored")
            }
        }
    }
}