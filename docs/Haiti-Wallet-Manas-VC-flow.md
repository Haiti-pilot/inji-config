# Haiti Wallet: Manas-compatible credential rendering

The current Haiti Wallet uses the MOSIP VCI SDK for eSignet OAuth, credential issuance, signature verification and storage. It now normalizes issuer-signed credential envelopes in `shared/vciClient/CredentialPayload.ts` in the same manner as `Manas0606/manas-wallet` and applies recursive, localized credential claim extraction. For UIN/VID, only explicitly named signed claims are accepted; `credentialSubject.id` is never used as a substitute.

## Current GitHub SVG (no DB change)

The Haiti Wallet downloads `https://raw.githubusercontent.com/Manas0606/inji-config/haiti-0.14.0-aws/haiti-national-id-wallet-v3.svg` and renders it locally using dynamic `wallet/claimRowsSvg` and sizing placeholders. It also renders a separate QR component from issuer-supplied signed `claim169` or from PixelPass-encoded credential data when possible.

**Do not paste this v3 SVG directly into Certify's `rendering_template` table:** the dynamic `wallet/*` placeholders are specific to the Haiti application, not the generic SVG-Mustache renderer. No DB change is required for the current GitHub SVG.

## Haiti current deployment: no Certify SVG database integration

The Haiti Wallet fetches the versioned SVG from `inji-config` and populates it locally. The `rendering_template` table is **not used** by this Haiti-specific rendering path. The obsolete `rendering-template-id` property and its unused SQL/SVG files were reverted on 17 November 2026.

Inji Certify continues using `credential_config.vc_template` (Base64-encoded Velocity) to issue and sign credential claims, including UIN/VID when present in authorized IDA data. That issuance template is **not** the Wallet visual SVG.

Read-only check of active issuance configuration:

```sql
SELECT config_id, status, scope, credential_format,
       length(vc_template) AS vc_template_length,
       credential_subject, qr_settings, qr_signature_algo
FROM credential_config
WHERE scope = 'mosip_identity_vc_ldp';
```

Do not delete or alter `credential_config` as part of removing the unused SVG database rendering setup.

## Why UIN/VID or QR may still be absent

If UIN/VID does not exist in the signed VC, the Wallet cannot populate it. Check the data provider and credential issuance template and follow country disclosure policy. If `claim169` is absent, the Wallet uses PixelPass and rejects oversized or unverified QR payloads; an arbitrary QR image in an SVG is **not** verifier-compatible QR data. Avoid fabricating signed identifiers or modifying signature/proof material.
