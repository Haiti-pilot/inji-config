# Haiti national ID VC rendering template rollout

## Files
- `haiti-national-id-v1.svg`: French SVG view for Haiti identity credentials (client-side visual only, no QR is embedded).
- `sql/haiti-national-id-v1-rendering-template.sql`: safe insert into the **Inji Certify** PostgreSQL `rendering_template` table.
- `certify-mosipid-identity.properties`: data provider property `mosip.certify.data-provider-plugin.rendering-template-id=haiti-national-id-v1`.

## Deploy sequence
1. In pgAdmin Query Tool, select the **Haiti Inji Certify** database. Run the SQL file. Verify the ID exists.
2. Verify `GET https://injicertify.haiti-pilot.mosip.net/v1/certify/rendering-template/haiti-national-id-v1` returns `image/svg+xml`. The URL must be reachable from the phone.
3. Deploy the updated `certify-mosipid-identity.properties` to the relevant Haiti Certify configuration source, then roll the Certify pod safely. If a different file overrides this property in Rancher, set it there instead.
4. **Required**: in the active `credential_config.vc_template`, add the `renderMethod` stanza **before issuing** a new VC. The template is a Base64-encoded Velocity document, so preserve all existing fields and conditional syntax. Do not blindly rewrite it using SQL regex.
5. The `renderMethod` portion of the Velocity **VC issuance template** should be:
```json
"renderMethod": [{
  "type": "TemplateRenderMethod",
  "renderSuite": "svg-mustache",
  "template": {
    "id": "https://injicertify.haiti-pilot.mosip.net/v1/certify/rendering-template/haiti-national-id-v1",
    "mediaType": "image/svg+xml",
    "digestMultibase": "${_renderMethodSVGdigest}"
  }
}]
```
Certify populates `${_renderMethodSVGdigest}` when the plugin rendering-template-id is set. This stanza is part of the signed VC payload, not the SVG.
6. Inspect the issued VC. It must have `renderMethod` and a matching template URL + digest. Re-download a **newly issued VC** after the Certify change; old VCs may not have a renderMethod.
7. `credentialSubject/firstName`, `lastName`, `middleName`, `dateOfBirth`, `gender`, `department`, `commune`, and `locality` placeholders in the SVG must match the actual signed VC schema. Update only when you have verified claim names. Changing the SVG content after issuing a VC breaks the integrity digest: version the ID (`-v2`) instead.

## Database inspection (pgAdmin)
```sql
SELECT id, length(template) AS svg_length
FROM rendering_template WHERE id = 'haiti-national-id-v1';

SELECT config_id, status, credential_format, scope,
       left(convert_from(decode(vc_template, 'base64'), 'UTF8'), 2000) AS vc_template_preview
FROM credential_config
WHERE scope = 'mosip_identity_vc_ldp';
```
The second query works if the active template is stored as Base64 (as in Certify docs). If it is plain text, inspect it separately instead. Keep its exact original content for rollback.

## Wallet binding / online activation
Rendering is unrelated to binding. The Haiti Inji Wallet already implements `/v1/mimoto/binding-otp` and `/v1/mimoto/wallet-binding`. After downloading a **verified VC containing UIN or VID**, tapping Activer requests an OTP, sends the phone public key and OTP to Mimoto, and stores a successful binding. Both Haiti Mimoto and the eSignet binding backend must support these calls. **Do not assume activation is enabled merely because the SVG inserts successfully.**

Check the following before calling activation complete:
- VC metadata has a nonempty individual ID extracted from a UIN/VID claim (do not display or log full ID).
- POST `https://api.haiti-pilot.mosip.net/v1/mimoto/binding-otp` returns no errors and a transaction ID.
- POST `https://api.haiti-pilot.mosip.net/v1/mimoto/wallet-binding` returns `encryptedWalletBindingId` and `thumbprint`.
- The Wallet shows activation success and can complete the linked-login flow after restarting.

**Do not test with fabricated UIN/VID or commit real OTPs, tokens, keys, or personal identities.**
