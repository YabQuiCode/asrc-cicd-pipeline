# 05 - Preuve recette simulée

## Workflow de validation recette

- Workflow concerné : `03-promote.yml`
- Environnement GitHub : `recette`
- Tag source validé : *(à compléter — ex : latest ou sha-1e0ec87)*
- Digest observé : *(à compléter — copier depuis le résumé du run)*
- Lien du run : *(à compléter — aller dans Actions > 03 - Promotion recette vers production-simulee > copier le lien)*

## Résultat

Le workflow de validation recette effectue les opérations suivantes sans reconstruire l'image :

1. **Pull de l'image existante** depuis GHCR avec le tag spécifié lors du déclenchement manuel.
2. **Lancement du conteneur** sur le port 8080 du runner GitHub.
3. **Tests HTTP** : vérification que la page d'accueil et le fichier version.json sont accessibles et répondent correctement.
4. **Résumé** : le digest de l'image et le tag source sont affichés dans le Step Summary du workflow.

Résultat observé : *(à compléter — ex : "L'image a été téléchargée depuis GHCR, le conteneur a démarré avec succès, les deux requêtes HTTP (/ et /version.json) ont renvoyé un code 200. Le digest observé correspond bien à celui de la publication initiale.")*

## Point important

La validation recette utilise un **environnement GitHub** nommé `recette`. Cet environnement peut être configuré dans les paramètres du dépôt (Settings > Environments) pour ajouter des règles de protection : approbation manuelle, restriction de branches, ou délai d'attente. Dans ce projet, l'environnement est créé automatiquement lors du premier run du workflow.
