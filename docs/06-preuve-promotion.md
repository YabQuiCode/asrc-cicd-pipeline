# 06 - Preuve promotion production-simulee

## Promotion

- Workflow concerné : `03-promote.yml`
- Environnement GitHub : `production-simulee`
- Tag source : *(à compléter — ex : latest)*
- Tag cible : `production-simulee`
- Lien du run : *(à compléter)*

## Point essentiel

La promotion doit réutiliser une image existante. Elle ne doit pas reconstruire l'image.

Concrètement, le job `promote-production-simulee` effectue trois opérations :

1. `docker pull` — télécharge l'image existante depuis GHCR avec le tag source.
2. `docker tag` — applique le nouveau tag `production-simulee` à cette même image locale.
3. `docker push` — pousse l'image re-taguée dans GHCR.

Aucune étape de build n'est présente dans ce job. L'image binaire qui arrive en production-simulee est strictement identique à celle validée en recette.

## Preuve

La preuve que la promotion s'est faite sans rebuild repose sur plusieurs éléments :

- **Absence de step "build"** : le job `promote-production-simulee` dans le workflow ne contient aucune action `docker/build-push-action` ni de commande `docker build`.
- **Même digest** : le digest SHA256 de l'image taguée `production-simulee` est identique à celui de l'image source. On peut le vérifier en comparant les digests dans GHCR ou dans les résumés des runs.
- **Dépendance séquentielle** : le job de promotion ne s'exécute qu'après la validation recette (`needs: validate-recette`), garantissant que seule une image validée peut être promue.
- **Logs GitHub Actions** : les logs du run montrent clairement un `docker pull` suivi d'un `docker tag` et `docker push`, sans aucun `docker build`.
