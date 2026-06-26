package com.kelvin.mpesa.mpesa_tracker

data class MpesaMessage(
    val transactionCode: String,
    val amount: Double,
    val transactionCost: Double,
    val recipient: String,
    val accountReference: String,
    val balanceAfter: Double,
    val timestamp: String,
    val direction: String,
    val messageType: String
)

object MpesaParser {

    private fun cleanBody(body: String): String {
        return body
            .replace(Regex("Download[^\n]*", RegexOption.IGNORE_CASE), "")
            .replace(Regex("Separate personal[^\n]*", RegexOption.IGNORE_CASE), "")
            .replace(Regex("Amount you can transact[^\n]*", RegexOption.IGNORE_CASE), "")
            .trim()
    }

    fun isOutgoing(sender: String, body: String): Boolean {
        val isMpesa = sender.contains("MPESA", ignoreCase = true)
        val outKeywords = listOf(
            "sent to", "paid to", "bought", "withdrew",
            "transferred to m-shwari",
            "transfered to kcb m-pesa",
            "transferred to kcb m-pesa"
        )
        val isOut = outKeywords.any { body.contains(it, ignoreCase = true) }
        return isMpesa && isOut
    }

    fun isIncoming(sender: String, body: String): Boolean {
        val isMpesa = sender.contains("MPESA", ignoreCase = true)
        val inKeywords = listOf(
            "you have received",
            "have received",
            "transferred from m-shwari",
            "transferred from kcb m-pesa"
        )
        val isIn = inKeywords.any { body.contains(it, ignoreCase = true) }
        return isMpesa && isIn
    }

    fun parse(body: String, direction: String): MpesaMessage {
        val clean = cleanBody(body)

        // Transaction code
        val txCode = Regex("^([A-Z0-9]+)\\s+Confirmed", RegexOption.MULTILINE)
            .find(clean)?.groupValues?.get(1) ?: ""

        // Amount — handles both "Ksh" and "KSH"
        val amount = Regex("[Kk][Ss][Hh]([\\d,]+\\.\\d{2})")
            .find(clean)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull() ?: 0.0

        // Transaction cost — handles "Ksh.0.00" and "Ksh0.00" and "KSH0.00"
        val cost = Regex(
            "Transaction cost[,:]?\\s*[Kk][Ss][Hh]\\.?([\\d,]+\\.\\d{2})",
            RegexOption.IGNORE_CASE
        ).find(clean)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull() ?: 0.0

        // Balance — handles both "New M-PESA balance is" and "M-PESA balance is"
        val balance = Regex(
            "New M-PESA balance is [Kk][Ss][Hh]([\\d,]+\\.\\d{2})|M-PESA balance is [Kk][Ss][Hh]([\\d,]+\\.\\d{2})",
            RegexOption.IGNORE_CASE
        ).find(clean)?.let {
            // First group for "New M-PESA", second group for "M-PESA"
            (it.groupValues[1].ifEmpty { it.groupValues[2] })
                .replace(",", "").toDoubleOrNull()
        } ?: 0.0

        // Timestamp
        val timestamp = Regex(
            "(\\d{1,2}/\\d{1,2}/\\d{2,4})\\s+at\\s+(\\d{1,2}:\\d{2}\\s*[AP]M)"
        ).find(clean)?.value ?: ""

        var recipient = ""
        var accountRef = ""
        val messageType: String

        if (direction == "in") {
            when {
                // From M-Shwari
                clean.contains("transferred from M-Shwari", ignoreCase = true) -> {
                    recipient = "M-Shwari"
                    messageType = "mshwari_in"
                }

                // From KCB M-Pesa
                clean.contains("transferred from KCB M-PESA", ignoreCase = true) -> {
                    recipient = "KCB M-Pesa"
                    messageType = "kcbmpesa_in"
                }

                // From person with phone number
                Regex("received\\s+[Kk][Ss][Hh][\\d,.]+\\s+from\\s+([A-Za-z ]+?)\\s+(0\\d{9}|0\\d{3}\\*+\\d+)")
                    .containsMatchIn(clean) -> {
                    val match = Regex(
                        "received\\s+[Kk][Ss][Hh][\\d,.]+\\s+from\\s+([A-Za-z ]+?)\\s+(0\\d{9}|0\\d{3}\\*+\\d+)"
                    ).find(clean)!!
                    recipient = match.groupValues[1].trim()
                    messageType = "receive_money"
                }

                // From person with non-phone account number (e.g. 8739281)
                Regex("received\\s+[Kk][Ss][Hh][\\d,.]+\\s+from\\s+([A-Za-z ]+?)\\s+(\\d{5,})")
                    .containsMatchIn(clean) -> {
                    val match = Regex(
                        "received\\s+[Kk][Ss][Hh][\\d,.]+\\s+from\\s+([A-Za-z ]+?)\\s+(\\d{5,})"
                    ).find(clean)!!
                    recipient = match.groupValues[1].trim()
                    accountRef = match.groupValues[2].trim()
                    messageType = "receive_money"
                }

                // From bank or institution (followed by "on" + date)
                Regex("received\\s+[Kk][Ss][Hh][\\d,.]+\\s+from\\s+([A-Za-z ]+?)\\s+on\\s+\\d")
                    .containsMatchIn(clean) -> {
                    val match = Regex(
                        "received\\s+[Kk][Ss][Hh][\\d,.]+\\s+from\\s+([A-Za-z ]+?)\\s+on\\s+\\d"
                    ).find(clean)!!
                    recipient = match.groupValues[1].trim()
                    messageType = "bank_deposit"
                }

                else -> {
                    recipient = Regex("from\\s+([A-Za-z ]+)")
                        .find(clean)?.groupValues?.get(1)?.trim() ?: ""
                    messageType = "receive_money"
                }
            }

        } else {
            when {
                // To M-Shwari
                clean.contains("transferred to M-Shwari", ignoreCase = true) -> {
                    recipient = "M-Shwari"
                    messageType = "mshwari_out"
                }

                // To KCB M-Pesa (handles both "transfered" typo and "transferred")
                clean.contains("transfered to KCB M-PESA", ignoreCase = true) ||
                clean.contains("transferred to KCB M-PESA", ignoreCase = true) -> {
                    recipient = "KCB M-Pesa"
                    messageType = "kcbmpesa_out"
                }

                // Paybill — has "for account"
                clean.contains("for account", ignoreCase = true) -> {
                    recipient = Regex(
                        "(?:sent to|paid to)\\s+([A-Za-z0-9 ]+?)\\s+for account",
                        RegexOption.IGNORE_CASE
                    ).find(clean)?.groupValues?.get(1)
                        ?.trim()?.trimEnd('.') ?: ""
                    accountRef = Regex(
                        "for account\\s+([^\\s\\.]+)"
                    ).find(clean)?.groupValues?.get(1)?.trim() ?: ""
                    messageType = "paybill"
                }

                // Till payment — "paid to NAME."
                clean.contains("paid to", ignoreCase = true) -> {
                    recipient = Regex(
                        "paid to\\s+([A-Za-z ]+?)(?=\\s+on\\s+\\d|\\.\\s*on|\\.$|\\s*\\.\\s*New)",
                        RegexOption.IGNORE_CASE
                    ).find(clean)?.groupValues?.get(1)
                        ?.trim()?.trimEnd('.') ?: ""
                    messageType = "till_payment"
                }

                // Send money to person
                clean.contains("sent to", ignoreCase = true) -> {
                    recipient = Regex(
                        "sent to\\s+([A-Za-z ]+?)(?=\\s+0\\d{3}|\\s+on\\s+\\d)",
                        RegexOption.IGNORE_CASE
                    ).find(clean)?.groupValues?.get(1)
                        ?.trim()?.trimEnd('.') ?: ""
                    messageType = "send_money"
                }

                else -> {
                    recipient = ""
                    messageType = "send_money"
                }
            }
        }

        return MpesaMessage(
            txCode, amount, cost,
            recipient, accountRef,
            balance, timestamp,
            direction, messageType
        )
    }
}