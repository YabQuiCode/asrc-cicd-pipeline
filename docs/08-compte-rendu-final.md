# 08 - Compte rendu final

## 1. Synthèse

Ce projet met en place une chaîne CI/CD complète pour l'entreprise fictive Catal-Log. La chaîne automatise la construction, le test, la publication et la promotion d'une image Docker Nginx contenant un site web statique. L'ensemble repose sur GitHub Actions pour l'automatisation, GitHub Container Registry (GHCR) pour le stockage des images, et Docker Compose pour l'orchestration légère locale.

La chaîne est conçue pour être simple, lisible et traçable : chaque image publiée est identifiée par un tag SHA et un digest unique, et la promotion vers la production simulée se fait sans reconstruire l'image, garantissant que l'artefact déployé est exactement celui qui a été testé.

## 2. Fonctionnement technique

Le chemin complet d'une modification, du commit à la production simulée :

1. **Commit et push** : le développeur modifie le code et pousse sur GitHub.
2. **CI automatique (01-ci.yml)** : à chaque push, GitHub Actions vérifie la présence des fichiers obligatoires, valide la syntaxe Docker Compose, construit l'image Docker avec le SHA du commit comme tag, lance un conteneur et effectue des tests HTTP (page d'accueil, version.json, contenu attendu).
3. **Publication GHCR (02-publish-ghcr.yml)** : sur la branche main, l'image est construite, taguée (sha-xxxxxxx + latest) et publiée dans GHCR avec le GITHUB_TOKEN.
4. **Validation recette (03-promote.yml, job 1)** : déclenché manuellement, le workflow télécharge l'image depuis GHCR (sans rebuild), la lance dans l'environnement GitHub "recette" et effectue les mêmes tests HTTP.
5. **Promotion production-simulee (03-promote.yml, job 2)** : si la recette est validée, l'image est re-taguée `production-simulee` et poussée dans GHCR. Aucun rebuild n'a lieu.

## 3. Conteneurisation C12

Le **Dockerfile** est basé sur `nginx:1.27-alpine`, une image officielle minimale (~7 Mo). Il copie le contenu du dossier `site/` dans le répertoire de publication Nginx, ajuste les permissions et expose le port 80. Un healthcheck est configuré pour permettre à Docker de vérifier que le service répond.

L'image produite est reproductible : le même Dockerfile avec le même contexte de build produit toujours la même image. Les labels OCI (titre, description, source, auteur) sont intégrés pour la traçabilité.

Les preuves de conteneurisation incluent : le Dockerfile fonctionnel, les logs de build dans GitHub Actions, le test HTTP automatisé qui valide le bon fonctionnement du conteneur, et l'image publiée dans GHCR.

## 4. Orchestration et scaling C13

Le fichier `compose.yml` décrit deux services :

- **web** : le service principal Nginx avec healthcheck, politique de redémarrage `unless-stopped`, et réseau dédié.
- **tester** : un conteneur éphémère curl qui valide automatiquement le fonctionnement du service web.

La simulation de scaling avec `docker compose up -d --scale web=2` lance deux instances du service web sur le réseau interne. Cette simulation démontre la capacité de Docker Compose à coordonner plusieurs conteneurs, mais elle ne remplace pas une orchestration de production car il manque un load balancer, la haute disponibilité, la supervision et la gestion du scaling dynamique.

Docker Compose est un orchestrateur léger adapté au développement, aux tests et aux démonstrations. En production, Kubernetes serait nécessaire pour gérer le scaling automatique (HPA), la répartition de charge (Ingress/Service), la haute disponibilité (ReplicaSets sur plusieurs nœuds), les rolling updates et les rollbacks automatisés.

## 5. Automatisation et sécurité C14

Les trois workflows GitHub Actions automatisent l'intégralité du cycle de vie de l'image :

- Les **permissions** sont déclarées explicitement et limitées au strict nécessaire (principe du moindre privilège).
- Le **GITHUB_TOKEN** est utilisé pour l'authentification GHCR. C'est un token éphémère, automatiquement généré et révoqué par GitHub Actions, qui ne nécessite aucune gestion manuelle de secrets.
- **Aucun secret n'est stocké dans le code** : pas de mot de passe, pas de clé API, pas de token en clair dans les fichiers du dépôt.
- Le **rollback** est possible via les tags SHA et les digests : on peut promouvoir n'importe quelle version antérieure sans rebuild.
- La **sauvegarde** repose sur le versionnement Git (historique complet du code et des workflows) et la conservation des images dans GHCR.

## 6. Production réelle

### Gestion des secrets

En production réelle, on utiliserait GitHub Secrets pour les variables sensibles (clés SSH, tokens d'API tiers, identifiants de registre privé) et un coffre de secrets (HashiCorp Vault, AWS Secrets Manager) pour la rotation automatique et l'audit d'accès. Aucun secret ne doit jamais apparaître dans le code, les logs ou les variables d'environnement en clair.

### Rollback

Le rollback s'appuie sur la traçabilité des images : chaque version est identifiable par son tag SHA et son digest. Pour revenir en arrière, on relance la promotion avec le tag de la version souhaitée, ou on utilise le digest pour garantir l'immuabilité. L'image est déjà construite et testée, le rollback est donc quasi instantané.

### Sauvegarde / restauration

Il faudrait sauvegarder : le dépôt Git complet (clone miroir), les images GHCR critiques (export tar), la configuration des environnements GitHub, les secrets (via le coffre), et les preuves d'exécution (export des logs). La restauration consiste à re-cloner le dépôt, recréer les environnements et secrets, puis relancer les workflows.

### Éléments complémentaires

- **Contrôle des vulnérabilités** : intégration de Trivy ou Snyk dans la CI pour scanner les images avant publication.
- **Validation manuelle avant production** : règles de protection d'environnement GitHub (approbation obligatoire, restriction de branches) et revue de code par pull request.

## 7. Preuves

*(À compléter avec les liens réels après exécution des workflows)*

- Lien dépôt GitHub : https://github.com/YabQuiCode/asrc-cicd-pipeline
- Run CI réussi : *(lien à ajouter)*
- Run publication GHCR : *(lien à ajouter)*
- Image GHCR : https://github.com/YabQuiCode/asrc-cicd-pipeline/pkgs/container/asrc-cicd-pipeline
- Tag et digest : *(à ajouter)*
- Run promotion recette + production : *(lien à ajouter)*

## 8. Difficultés et apprentissages

*(Section à personnaliser avec votre expérience réelle)*

Ce projet m'a permis de comprendre concrètement le fonctionnement d'une chaîne CI/CD de bout en bout. Les points clés que j'ai retenus :

- L'importance de la **traçabilité** : chaque image est identifiable par son tag et son digest, ce qui permet de savoir exactement quelle version du code tourne en production.
- Le concept de **promotion sans rebuild** : ne pas reconstruire l'image entre les environnements garantit que ce qui est testé est exactement ce qui est déployé.
- Le principe du **moindre privilège** pour les permissions GitHub Actions : chaque workflow ne reçoit que les droits dont il a besoin.
- La différence entre **orchestration légère** (Docker Compose) et **orchestration de production** (Kubernetes) : Docker Compose est parfait pour le développement et les tests, mais insuffisant pour la production réelle.
