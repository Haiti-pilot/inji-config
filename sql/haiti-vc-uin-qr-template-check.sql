-- Haiti Inji Certify: READ-ONLY checks for VC claims and QR support.
-- Use pgAdmin against the INJI CERTIFY database. Does not modify data.
-- Checking the template does not prove values are present in issued VC.
-- Never paste full UIN, OTP, token, or personal record into support chats.

-- 1) Identify active credentials/templates for the Haiti scope.
SELECT config_id, scope, status, credential_format,
       length(vc_template) AS template_length
FROM credential_config
WHERE scope = 'mosip_identity_vc_ldp';

-- 2) Decode templates only if vc_template is stored as Base64 text.
--    Inspect one decoded template before deciding what to change.
--    If this produces invalid Base64, DO NOT run updates: check storage format.
SELECT config_id, scope, status,
       left(convert_from(decode(vc_template, 'base64'), 'UTF8'), 5000)
           AS decoded_template_preview
FROM credential_config
WHERE scope = 'mosip_identity_vc_ldp';

-- 3) Claim-presence checks in the issuance template, not personal data.
WITH decoded AS (
  SELECT config_id, status,
         convert_from(decode(vc_template, 'base64'), 'UTF8') AS body
  FROM credential_config
  WHERE scope = 'mosip_identity_vc_ldp'
)
SELECT config_id, status,
       body ~* '"(UIN|VID|individualId|mosipIndividualId)"'
           AS maps_explicit_uin_or_vid,
       body ~* '"fullName"' AS maps_full_name,
       body ~* '"(firstName|lastName)"' AS maps_first_last_names,
       body ~* '"(section|communalSection)"' AS maps_section,
       body ~* '"(localite|locality)"' AS maps_locality,
       body ~* '"claim169"' AS maps_issuer_qr_claim169
FROM decoded;
