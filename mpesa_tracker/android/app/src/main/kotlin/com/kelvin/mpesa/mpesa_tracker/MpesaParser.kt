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
    val messageType: String,
    val secondaryBalance: Double = 0.0,
    val secondaryAccount: String = ""
)

object MpesaParser {

    // All regex patterns are compiled once here rather than on every parse
    // call — SmsReceiver invokes this on every incoming SMS, so recompiling
    // ~15 patterns per message was repeated, avoidable work in a path that
    // now also spins up a headless Flutter engine per message.
    private val downloadNote = Regex("Download[^\n]*", RegexOption.IGNORE_CASE)
    private val separatePersonalNote =
        Regex("Separate personal[^\n]*", RegexOption.IGNORE_CASE)
    private val amountYouCanTransactNote =
        Regex("Amount you can transact[^\n]*", RegexOption.IGNORE_CASE)

    private val txCodePattern =
        Regex("^([A-Z0-9]+)\\s+Confirmed", RegexOption.MULTILINE)
    private val amountPattern = Regex("[Kk][Ss][Hh]([\\d,]+\\.\\d{2})")
    private val costPattern = Regex(
        "Transaction cost[,:]?\\s*[Kk][Ss][Hh]\\.?([\\d,]+\\.\\d{2})",
        RegexOption.IGNORE_CASE
    )
    private val balancePattern = Regex(
        "New M-PESA balance is [Kk][Ss][Hh]([\\d,]+\\.\\d{2})|M-PESA balance is [Kk][Ss][Hh]([\\d,]+\\.\\d{2})",
        RegexOption.IGNORE_CASE
    )
    private val timestampPattern = Regex(
        "(\\d{1,2}/\\d{1,2}/\\d{2,4})\\s+at\\s+(\\d{1,2}:\\d{2}\\s*[AP]M)"
    )

    private val receivedFromPhone = Regex(
        "received\\s+[Kk][Ss][Hh][\\d,.]+\\s+from\\s+([A-Za-z ]+?)\\s+(0\\d{9}|0\\d{3}\\*+\\d+)"
    )
    private val receivedFromAccountNumber = Regex(
        "received\\s+[Kk][Ss][Hh][\\d,.]+\\s+from\\s+([A-Za-z ]+?)\\s+(\\d{5,})"
    )
    private val receivedFromInstitution = Regex(
        "received\\s+[Kk][Ss][Hh][\\d,.]+\\s+from\\s+([A-Za-z ]+?)\\s+on\\s+\\d"
    )
    private val receivedFromFallback = Regex("from\\s+([A-Za-z ]+)")

    private val cashDepositRecipient = Regex(
        "cash to\\s+([A-Za-z ]+)", RegexOption.IGNORE_CASE
    )
    private val paybillRecipient = Regex(
        "(?:sent to|paid to)\\s+([A-Za-z0-9 ]+?)\\s+for account",
        RegexOption.IGNORE_CASE
    )
    private val paybillAccountRef = Regex("for account\\s+([^\\s\\.]+)")
    private val tillPaymentRecipient = Regex(
        "paid to\\s+([A-Za-z ]+?)(?=\\s+on\\s+\\d|\\.\\s*on|\\.$|\\s*\\.\\s*New)",
        RegexOption.IGNORE_CASE
    )
    private val sendMoneyRecipient = Regex(
        "sent to\\s+([A-Za-z ]+?)(?=\\s+0\\d{3}|\\s+on\\s+\\d)",
        RegexOption.IGNORE_CASE
    )

    private val mshwariBalancePattern = Regex(
        "(?:New )?M-Shwari (?:saving account )?balance is [Kk][Ss][Hh]([\\d,]+\\.\\d{2})",
        RegexOption.IGNORE_CASE
    )
    private val kcbMpesaBalancePattern = Regex(
        "new KCB M-PESA (?:Saving account )?balance is [Kk][Ss][Hh]([\\d,]+\\.\\d{2})",
        RegexOption.IGNORE_CASE
    )

    private fun cleanBody(body: String): String {
        return body
            .replace(downloadNote, "")
            .replace(separatePersonalNote, "")
            .replace(amountYouCanTransactNote, "")
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
            "transferred from kcb m-pesa",
            "give ksh"
        )
        val isIn = inKeywords.any { body.contains(it, ignoreCase = true) }
        return isMpesa && isIn
    }

    fun parse(body: String, direction: String): MpesaMessage {
        val clean = cleanBody(body)

        // Transaction code
        val txCode = txCodePattern.find(clean)?.groupValues?.get(1) ?: ""

        // Amount — handles both "Ksh" and "KSH"
        val amount = amountPattern.find(clean)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull() ?: 0.0

        // Transaction cost — handles "Ksh.0.00" and "Ksh0.00" and "KSH0.00"
        val cost = costPattern.find(clean)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull() ?: 0.0

        // Balance — handles both "New M-PESA balance is" and "M-PESA balance is"
        val balance = balancePattern.find(clean)?.let {
            // First group for "New M-PESA", second group for "M-PESA"
            (it.groupValues[1].ifEmpty { it.groupValues[2] })
                .replace(",", "").toDoubleOrNull()
        } ?: 0.0

        // Timestamp
        val timestamp = timestampPattern.find(clean)?.value ?: ""

        var recipient = ""
        var accountRef = ""
        val messageType: String

        if (direction == "in") {
            val phoneMatch = receivedFromPhone.find(clean)
            val accountMatch = receivedFromAccountNumber.find(clean)
            val institutionMatch = receivedFromInstitution.find(clean)

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
                phoneMatch != null -> {
                    recipient = phoneMatch.groupValues[1].trim()
                    messageType = "receive_money"
                }

                // From person with non-phone account number (e.g. 8739281)
                accountMatch != null -> {
                    recipient = accountMatch.groupValues[1].trim()
                    accountRef = accountMatch.groupValues[2].trim()
                    messageType = "receive_money"
                }

                // From bank or institution (followed by "on" + date)
                institutionMatch != null -> {
                    recipient = institutionMatch.groupValues[1].trim()
                    messageType = "bank_deposit"
                }

                else -> {
                    recipient = receivedFromFallback.find(clean)
                        ?.groupValues?.get(1)?.trim() ?: ""
                    messageType = "receive_money"
                }
            }

        } else {
            when {
                // Cash deposit at agent
                clean.contains("give ksh", ignoreCase = true) -> {
                    recipient = cashDepositRecipient.find(clean)
                        ?.groupValues?.get(1)?.trim() ?: "Agent"
                    messageType = "cash_deposit"
                }

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
                    recipient = paybillRecipient.find(clean)?.groupValues?.get(1)
                        ?.trim()?.trimEnd('.') ?: ""
                    accountRef = paybillAccountRef.find(clean)
                        ?.groupValues?.get(1)?.trim() ?: ""
                    messageType = "paybill"
                }

                // Till payment — "paid to NAME."
                clean.contains("paid to", ignoreCase = true) -> {
                    recipient = tillPaymentRecipient.find(clean)?.groupValues?.get(1)
                        ?.trim()?.trimEnd('.') ?: ""
                    messageType = "till_payment"
                }

                // Send money to person
                clean.contains("sent to", ignoreCase = true) -> {
                    recipient = sendMoneyRecipient.find(clean)?.groupValues?.get(1)
                        ?.trim()?.trimEnd('.') ?: ""
                    messageType = "send_money"
                }

                else -> {
                    recipient = ""
                    messageType = "send_money"
                }
            }
        }

        // Extract secondary account balance if present
        var secondaryBalance = 0.0
        var secondaryAccount = ""

        val mshwariBalance = mshwariBalancePattern.find(clean)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull()

        val kcbMpesaBalance = kcbMpesaBalancePattern.find(clean)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull()

        when {
            mshwariBalance != null -> {
                secondaryBalance = mshwariBalance
                secondaryAccount = "M-Shwari"
            }
            kcbMpesaBalance != null -> {
                secondaryBalance = kcbMpesaBalance
                secondaryAccount = "KCB M-Pesa"
            }
        }

        return MpesaMessage(
            txCode, amount, cost,
            recipient, accountRef,
            balance, timestamp,
            direction, messageType,
            secondaryBalance, secondaryAccount
        )
    }
}
