# ============================================================
# Multi-stage build : React (Vite) → Nginx Alpine
# ============================================================

# --- Stage 1 : Build de l'application React ---
FROM node:20-alpine AS builder

WORKDIR /app

# Copier les fichiers de dépendances en premier (cache Docker)
COPY site/package.json site/package-lock.json ./
RUN npm ci --silent

# Copier le reste du code source
COPY site/ ./

# Build de production
RUN npm run build

# --- Stage 2 : Image Nginx légère ---
FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="Projet CICD - Catal-Log"
LABEL org.opencontainers.image.description="Image Nginx servant un site statique pour l'évaluation EC06"
LABEL org.opencontainers.image.source="https://github.com/YabQuiCode/asrc-cicd-pipeline"
LABEL org.opencontainers.image.authors="etudiant_15"

# Copier le build React dans Nginx
COPY --from=builder /app/dist/ /usr/share/nginx/html/
RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -q -O - http://127.0.0.1/ >/dev/null || exit 1
