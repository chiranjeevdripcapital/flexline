# ACH authorization letter — placeholder (non-legal)

**Purpose:** Stand-in content until legal delivers the **production PDF** for Adobe Acrobat Sign. **Do not use this text as a binding agreement.** Replace entirely with counsel-approved copy and, if required by the integration, **Adobe Sign text tags** in the PDF.

**Product placement:** Sent for e-signature **after** Plaid IAV **or** micro-deposit ownership verification succeeds, and **before** the bank account is treated as fully authorized for draws. See `docs/mvp-prd.md` §4.3.3 and §4.9.

**Integration reference:** [Adobe eSign API (GitBook — Bluebird Third-Party API)](https://dripcapital-1.gitbook.io/third-party-api-docs/5iVFAdCGrNAmNvJUnBTJ/adobe-esign-api).

---

## Placeholder body (replace with legal PDF)

**ACH debit authorization — draft outline only**

1. **Parties:** [Borrower legal name] (“Company”) authorizes [creditor / servicer legal name] (“Lender”) to initiate ACH debits from the bank account identified below.

2. **Account:** Financial institution [bank name], routing number [routing], account number ending in [last 4], account type [checking/savings], account holder name as on file [name].

3. **Authorization scope:** Debits for scheduled repayments, fees, and corrections as described in the loan / line documents [reference IDs]. Amounts and timing follow the disclosed schedule unless varied by written notice as permitted by agreement and law.

4. **Revocation:** Plain-language summary of how revocation may be requested and how it interacts with outstanding obligations (legal to draft).

5. **Certifications:** Company confirms it is authorized to bind the entity and that the account is enabled for ACH.

6. **Signature:** [Signer name and title], [date].

---

## Engineering notes

- Swap this markdown for a **binary PDF** in the app; the markdown file documents intent only.
- Map webhook / callback from `adobe_esign_upload` and signing flows to bank-account **ACH authorization status** and store the **signed PDF** returned by the integration.
- When legal provides the final PDF, remove references to this placeholder from user-facing copy.
