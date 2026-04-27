# Projet CI/CD – EC06 ASRC

## Contexte

Projet individuel réalisé dans le cadre de l'évaluation **EC06** du diplôme **Administrateur Systèmes, Réseaux et Cybersécurité (ASRC – RNCP39611)**.

L'entreprise fictive **Catal-Log** souhaite industrialiser la publication d'un site web statique via une chaîne CI/CD simple, lisible et traçable.

## Chaîne CI/CD

1. **01-ci.yml** — Build Docker + tests HTTP automatisés à chaque push
2. **02-publish-ghcr.yml** — Publication de l'image dans GitHub Container Registry (tag SHA + latest)
3. **03-promote.yml** — Validation recette simulée puis promotion vers production-simulee sans rebuild

## Structure du dépôt

```
.
├── .github/workflows/     # Pipelines GitHub Actions
│   ├── 01-ci.yml
│   ├── 02-publish-ghcr.yml
│   └── 03-promote.yml
├── docs/                  # Documentation et preuves
├── site/                  # Site statique (index.html + version.json)
├── Dockerfile             # Image Nginx Alpine
├── compose.yml            # Orchestration légère + second service
└── README.md
```

## Auteur

**Yoann** — [YabQuiCode](https://github.com/YabQuiCode)

## Lien GHCR

`ghcr.io/yabquicode/asrc-cicd-pipeline`
