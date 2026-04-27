# 01 - Cadrage du projet

## Identité

- Nom et prénom : Yoann
- Dépôt GitHub : https://github.com/YabQuiCode/asrc-cicd-pipeline
- Date de démarrage : 2026-04-27

## Objectif

Mettre en place une chaîne CI/CD permettant de construire, tester, publier et promouvoir une image Docker Nginx contenant un site web statique pour le scénario Catal-Log.

Le but est de démontrer la maîtrise des compétences C12 (conteneurisation), C13 (orchestration légère) et C14 (automatisation et sécurité DevOps) dans un contexte professionnel simulé.

## Contraintes du projet

- Travail individuel.
- Aucune infrastructure fournie, préparée, administrée ou maintenue par le formateur.
- Pas de serveur distant, pas de SSH, pas de cloud provider imposé.
- Les traitements principaux sont exécutés dans GitHub Actions.
- Docker local est utilisé pour les tests et la validation avant push.
- Une VM personnelle n'est pas utilisée dans ce projet car Docker Desktop est directement disponible sur le poste de travail, ce qui suffit pour les tests locaux et la simulation de scaling.

## Choix personnels

- **Dépôt public** : permet au formateur d'accéder directement au dépôt, aux workflows GitHub Actions et au registre GHCR sans invitation.
- **Nommage** : `asrc-cicd-pipeline` — explicite sur la formation et le sujet.
- **Stratégie de tags** : utilisation du préfixe `sha-` suivi des 7 premiers caractères du commit SHA pour la traçabilité, plus le tag `latest` sur la branche main. Le tag `production-simulee` est ajouté lors de la promotion.
- **Environnement local** : Docker Desktop est installé et fonctionnel, ce qui permet les tests locaux avec `docker build` et `docker compose up`.
- **VM personnelle** : non utilisée. Docker Desktop sur le poste fournit un environnement suffisant pour le build, les tests et la simulation de scaling. L'utilisation d'une VM n'apporterait pas de valeur ajoutée significative dans ce contexte.
