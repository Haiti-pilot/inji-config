-- Haiti National ID SVG template (Inji Certify PostgreSQL).
-- Idempotent insert. A published template must not be changed in-place:
-- previously issued credentials may pin its digestMultibase.
-- Execute in the inji_certify database using pgAdmin Query Tool.
BEGIN;
INSERT INTO rendering_template (id, template, cr_dtimes, upd_dtimes)
VALUES (
  'haiti-national-id-v1',
  $haiti_svg$
<svg xmlns="http://www.w3.org/2000/svg" width="350" height="560" viewBox="0 0 350 560">
  <defs>
    <linearGradient id="haitiBg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#f3f8fa"/>
      <stop offset="100%" stop-color="#dcecef"/>
    </linearGradient>
  </defs>
  <rect width="350" height="560" rx="20" fill="url(#haitiBg)"/>
  <rect x="8" y="8" width="334" height="544" rx="15" fill="none" stroke="#7f9a9e" stroke-width="1"/>
  <text x="175" y="35" font-size="16" font-weight="bold" font-family="sans-serif" fill="#153d4d" text-anchor="middle">RÉPUBLIQUE D'HAÏTI</text>
  <text x="175" y="58" font-size="13" font-weight="bold" font-family="sans-serif" fill="#153d4d" text-anchor="middle">OFFICE NATIONAL D'IDENTIFICATION</text>
  <text x="175" y="79" font-size="13" font-family="sans-serif" fill="#153d4d" text-anchor="middle">Carte d'Identification Nationale</text>
  <line x1="20" y1="93" x2="330" y2="93" stroke="#73959a" stroke-width="1"/>
  <g font-family="sans-serif" fill="#193943">
    <text x="20" y="118" font-size="11" fill="#516a70">Nom</text>
    <text x="20" y="138" font-size="15" font-weight="bold">{{credentialSubject/lastName}}</text>
    <text x="20" y="161" font-size="11" fill="#516a70">Prénom</text>
    <text x="20" y="181" font-size="15" font-weight="bold">{{credentialSubject/firstName}}</text>
    <text x="20" y="204" font-size="11" fill="#516a70">Deuxième prénom</text>
    <text x="20" y="224" font-size="13" font-weight="bold">{{credentialSubject/middleName}}</text>
    <text x="20" y="247" font-size="11" fill="#516a70">Date de naissance</text>
    <text x="20" y="267" font-size="14" font-weight="bold">{{credentialSubject/dateOfBirth}}</text>
    <text x="20" y="290" font-size="11" fill="#516a70">Sexe</text>
    <text x="20" y="310" font-size="14" font-weight="bold">{{credentialSubject/gender}}</text>
    <line x1="20" y1="326" x2="330" y2="326" stroke="#b6cacc" stroke-width="1"/>
    <text x="20" y="348" font-size="11" fill="#516a70">Département</text>
    <text x="20" y="366" font-size="13" font-weight="bold">{{credentialSubject/department}}</text>
    <text x="20" y="389" font-size="11" fill="#516a70">Commune</text>
    <text x="20" y="407" font-size="13" font-weight="bold">{{credentialSubject/commune}}</text>
    <text x="20" y="430" font-size="11" fill="#516a70">Localité</text>
    <text x="20" y="448" font-size="12" font-weight="bold">{{credentialSubject/locality}}</text>
    <text x="20" y="471" font-size="11" fill="#516a70">Type de pièce</text>
    <text x="20" y="489" font-size="12" font-weight="bold">Carte d'Identification Nationale</text>
  </g>
  <line x1="20" y1="506" x2="330" y2="506" stroke="#73959a" stroke-width="1"/>
  <text x="175" y="526" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#516a70">Document d'identité numérique - Haïti</text>
  <text x="175" y="542" font-family="sans-serif" font-size="9" text-anchor="middle" fill="#516a70">Données affichées issues du justificatif signé</text>
</svg>
$haiti_svg$,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;

SELECT id, length(template) AS svg_bytes, cr_dtimes, upd_dtimes
FROM rendering_template WHERE id = 'haiti-national-id-v1';
COMMIT;
