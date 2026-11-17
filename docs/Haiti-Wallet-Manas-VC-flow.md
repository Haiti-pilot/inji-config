# Haiti Wallet: Manas-compatible credential rendering

The current Haiti Wallet uses the MOSIP VCI SDK for eSignet OAuth, credential issuance, signature verification and storage. It now normalizes issuer-signed credential envelopes in `shared/vciClient/CredentialPayload.ts` in the same manner as `Manas0606/manas-wallet` and applies recursive, localized credential claim extraction. For UIN/VID, only explicitly named signed claims are accepted; `credentialSubject.id` is never used as a substitute.

## Current GitHub SVG (no DB change)

The Haiti Wallet downloads `https://raw.githubusercontent.com/Manas0606/inji-config/haiti-0.14.0-aws/haiti-national-id-wallet-v3.svg` and renders it locally using dynamic `wallet/claimRowsSvg` and sizing placeholders. It also renders a separate QR component from issuer-supplied signed `claim169` or from PixelPass-encoded credential data when possible.

**Do not paste this v3 SVG directly into Certify's `rendering_template` table:** the dynamic `wallet/*` placeholders are specific to the Haiti application, not the generic SVG-Mustache renderer. No DB change is required for the current GitHub SVG.

## Verified Inji Certify database schema

`credential_config.vc_template` contains the Base64-encoded issuance Velocity template. It controls what ends up in the signed VC, not the SVG appearance. `rendering_template(id, template, cr_dtimes, upd_dtimes)` is a separate optional SVG store for the VC's signed `renderMethod`.

Run the following **read-only** SQL in the Haiti `inji_certify` PostgreSQL database:

```sql
SELECT config_id, status, scope, credential_format,
       length(vc_template) AS vc_template_length,
       credential_subject, qr_settings, qr_signature_algo
FROM credential_config
WHERE scope = 'mosip_identity_vc_ldp';

WITH decoded AS (
  SELECT config_id, status,
         convert_from(decode(vc_template, 'base64'), 'UTF8') AS body
  FROM credential_config
  WHERE scope = 'mosip_identity_vc_ldp'
)
SELECT config_id, status,
       body ~* '"(UIN|VID|individualId|mosipIndividualId)"' AS maps_uin_vid,
       body ~* '"(fullName|firstName|lastName)"' AS maps_name,
       body ~* '"(section|communalSection)"' AS maps_section,
       body ~* '"(localite|locality)"' AS maps_localite,
       body ~* '"claim169"' AS maps_claim169,
       body ~* '"renderMethod"' AS maps_render_method
FROM decoded;

SELECT id, length(template) AS svg_length, upd_dtimes
FROM rendering_template ORDER BY id;
```

This checks the *issuance configuration*, not whether the identity data provider actually returns each field. Confirm field names in a newly issued, signature-verified VC with identifying values masked before changing anything.

## When DB-backed SVG is appropriate

Manas Wallet invokes its official native SVG renderer only when an LDP VC advertises `renderMethod`. This is optional. To adopt it:

1. Prepare an **immutable renderer-compatible SVG**, using supported `{{credentialSubject/field}}` placeholders; not the app-specific `{{wallet/*}}` format.
2. Register the SVG via the supported Certify rendering-template workflow or carefully reviewed DB migration.
3. Add the corresponding `renderMethod` URL and correct `digestMultibase` to the signed VC issuance Velocity template (or configure the Certify rendering-template ID so Certify supplies the digest).
4. Reissue the VC. Existing credentials do not acquire new signed claims or a renderMethod after issuance.
5. Use the Wallet's native `VcRenderer` when `renderMethod` exists, with a fallback.

Reference: `Haiti-pilot/inji-certify/docs/Rendering-Template.md`. A pod restart may be needed only for a changed server-side property/deployment, not for a GitHub SVG change.

## Why UIN/VID or QR may still be absent

If UIN/VID does not exist in the signed VC, the Wallet cannot populate it. Check the data provider and credential issuance template and follow country disclosure policy. If `claim169` is absent, the Wallet uses PixelPass and rejects oversized or unverified QR payloads; an arbitrary QR image in an SVG is **not** verifier-compatible QR data. Avoid fabricating signed identifiers or modifying signature/proof material.
