package com.kelvin.mpesa.mpesa_tracker

data class MpesaMessage(
    val transactionCode: String,
    val amount: Double,
    val transactionCost: Double,
    val recipient: String,
    val balanceAfter: Double,
    val timestamp: String,
    val direction: String  // "out" or "in"
)

object MpesaParser {

    fun isOutgoing(sender: String, body: String): Boolean {
        val isMpesa = sender.contains("MPESA", ignoreCase = true)
        val outKeywords = listOf("sent to", "paid to", "bought", "withdrew", "payment to")
        val isOut = outKeywords.any { body.contains(it, ignoreCase = true) }
        return isMpesa && isOut
    }

    fun isIncoming(sender: String, body: String): Boolean {
        val isMpesa = sender.contains("MPESA", ignoreCase = true)
        val inKeywords = listOf("received", "you have received")
        val isIn = inKeywords.any { body.contains(it, ignoreCase = true) }
        return isMpesa && isIn
    }

    fun parse(body: String, direction: String): MpesaMessage {
        val txCode = Regex("^([A-Z0-9]+) Confirmed", RegexOption.MULTILINE)
            .find(body)?.groupValues?.get(1) ?: ""

        val amount = Regex("Ksh([\\d,]+\\.\\d{2})")
            .find(body)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull() ?: 0.0

        val cost = Regex("Transaction cost[,:]?\\s*Ksh([\\d,]+\\.\\d{2})", RegexOption.IGNORE_CASE)
            .find(body)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull() ?: 0.0

        val recipient = when (direction) {
            "in" -> Regex("from\\s+([A-Za-z ]+?)(?=\\s+0\\d{3}|\\s+\\d{4})")
                .find(body)?.groupValues?.get(1)?.trim() ?: ""
            else -> Regex("(?:sent to|paid to|payment to)\\s+([A-Za-z ]+?)(?=\\s+for|\\s+on|\\.|,|\\d)")
                .find(body)?.groupValues?.get(1)?.trim() ?: ""
            }

        val balance = Regex("balance is Ksh([\\d,]+\\.\\d{2})", RegexOption.IGNORE_CASE)
            .find(body)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull() ?: 0.0

        val timestamp = Regex("(\\d{1,2}/\\d{1,2}/\\d{2,4})\\s+at\\s+(\\d{1,2}:\\d{2}\\s*[AP]M)")
            .find(body)?.value ?: ""

        return MpesaMessage(txCode, amount, cost, recipient, balance, timestamp, direction)
    }
}