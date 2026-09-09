#!/usr/bin/env bash
# Datasets hors git (OC-ADR-003). Ce script n'en télécharge pas : il documente la source.
set -euo pipefail

cat <<'EOF'
P8 — Cityscapes (segmentation sémantique urbaine)

Source amont (inscription obligatoire) :
  https://www.cityscapes-dataset.com/

Le repo contient uniquement un petit échantillon sous
  notebooks/content/data/test_images_sample/
  notebooks/content/data/new_images_to_predict/
pour la démo. Le dataset complet (~11 Go leftImg8bit + gtFine) ne doit
pas être versionné.

Copie locale (Nextcloud, sync PC ↔ NAS, **pas** de lien de partage public pour l'instant) :
  Master_openclassroom_AI_Engineer/08 …/data/
    P8_Cityscapes_leftImg8bit_trainvaltest.zip
    P8_Cityscapes_gtFine_trainvaltest.zip
EOF
