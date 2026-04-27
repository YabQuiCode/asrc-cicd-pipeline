# 07 - Sécurité minimale

## Permissions GitHub Actions

Chaque workflow utilise des permissions explicites et minimales, conformément au principe du moindre privilège :

- **01-ci.yml** : `contents: read` — le workflow n'a besoin que de lire le code source pour le construire et le tester. Il ne publie rien et ne modifie pas le dépôt.
- **02-publish-ghcr.yml** : `contents: read` + `packages: write` — en plus de lire le code, ce workflow doit pouvoir publier l'image dans GHCR (qui fait partie des "packages" GitHub).
- **03-promote.yml** : `contents: read` + `packages: write` — similaire au workflow de publication, car il doit pouvoir pousser un nouveau tag dans GHCR.

Déclarer les permissions explicitement au niveau du workflow (plutôt que de laisser les permissions par défaut) est une bonne pratique de sécurité : cela empêche un workflow compromis d'effectuer des actions non prévues (ex : modifier le code, créer des issues, accéder à d'autres ressources).

## Gestion des secrets

**Pourquoi aucun secret ne doit être stocké dans le code :**

Le code source est versionné dans Git. Tout ce qui est commité est conservé dans l'historique, même après suppression. Un secret (mot de passe, clé API, token) commité dans le code est donc exposé à toute personne ayant accès au dépôt, aujourd'hui ou dans le futur. Sur un dépôt public, c'est une faille de sécurité critique.

**Usage du GITHUB_TOKEN dans ce projet :**

Le `GITHUB_TOKEN` est un token éphémère généré automatiquement par GitHub Actions pour chaque run de workflow. Il est accessible via `${{ secrets.GITHUB_TOKEN }}` sans qu'aucun secret manuel n'ait été créé. Ses caractéristiques :
- Il est automatiquement créé au début du run et révoqué à la fin.
- Ses permissions sont celles déclarées dans le bloc `permissions:` du workflow.
- Il permet de s'authentifier auprès de GHCR pour publier et télécharger des images.
- Il ne nécessite aucune configuration manuelle dans les secrets du dépôt.

**Éléments à placer dans GitHub Secrets ou un coffre en production réelle :**

- Les clés SSH pour accéder à des serveurs de déploiement.
- Les tokens d'API tiers (ex : Slack pour les notifications, service de monitoring).
- Les identifiants de registre d'images privé (si on n'utilise pas GHCR).
- Les mots de passe de bases de données ou de services externes.
- Les certificats TLS ou clés de signature.

En production, on utiliserait un coffre de secrets comme HashiCorp Vault, AWS Secrets Manager ou Azure Key Vault pour gérer la rotation automatique et l'audit d'accès aux secrets.

## Rollback

Pour revenir à une version précédente, plusieurs stratégies sont possibles grâce à la traçabilité de la chaîne CI/CD :

1. **Par tag SHA** : chaque image publiée dans GHCR porte un tag `sha-xxxxxxx` correspondant au commit qui l'a produite. Pour revenir à une version antérieure, il suffit de relancer le workflow de promotion (`03-promote.yml`) avec le tag de l'ancienne version comme `source_tag`.

2. **Par digest** : si le tag a été écrasé, le digest SHA256 de l'image reste immuable. On peut toujours télécharger une image spécifique avec `docker pull ghcr.io/yabquicode/asrc-cicd-pipeline@sha256:...`.

3. **Par promotion d'un artefact antérieur** : la promotion est un simple re-tagging. On peut promouvoir n'importe quelle image existante dans GHCR vers `production-simulee`, sans rebuild. Cela permet un rollback rapide car l'image est déjà construite et testée.

4. **Par historique Git** : le code source est versionné. On peut revenir à un commit antérieur avec `git revert` ou `git checkout`, puis laisser la chaîne CI/CD reconstruire et republier l'image correspondante.

## Sauvegarde / restauration

Éléments à sauvegarder pour pouvoir restaurer l'ensemble du projet :

- **Dépôt GitHub** : le code source, l'historique des commits, les branches et les tags. Un clone complet (`git clone --mirror`) permet de sauvegarder l'intégralité de l'historique.
- **Workflows GitHub Actions** : ils font partie du code source (`.github/workflows/`) et sont donc sauvegardés avec le dépôt.
- **Documentation** : les fichiers `docs/*.md` sont versionnés dans le dépôt.
- **Images publiées dans GHCR** : les images Docker publiées sont conservées par GitHub. En cas de suppression accidentelle, il faudrait les reconstruire à partir du code source (d'où l'importance de conserver le Dockerfile et le contexte de build).
- **Configuration des environnements GitHub** : les environnements `recette` et `production-simulee` et leurs éventuelles règles de protection doivent être documentés pour être recréés si nécessaire.
- **Preuves d'exécution** : les logs des runs GitHub Actions sont conservés par GitHub pendant 90 jours par défaut. Pour une conservation plus longue, il est recommandé de capturer les résumés ou de les exporter.

Pour la restauration : cloner le dépôt sauvegardé, recréer les environnements GitHub, et relancer les workflows pour reconstruire et republier les images.

## Deux éléments complémentaires

### Contrôle des vulnérabilités

En production, il est essentiel de scanner les images Docker pour détecter les vulnérabilités connues (CVE) dans les dépendances et les couches de l'image. Des outils comme Trivy, Snyk ou GitHub Advanced Security (Dependabot + code scanning) peuvent être intégrés directement dans la chaîne CI/CD pour bloquer la publication d'une image contenant des vulnérabilités critiques. Dans ce projet, l'image de base `nginx:1.27-alpine` est choisie car Alpine Linux est une distribution minimale qui réduit la surface d'attaque.

### Validation manuelle avant production

Dans ce projet, la promotion vers `production-simulee` est déclenchée manuellement via `workflow_dispatch`, ce qui constitue déjà une forme de validation humaine. En production réelle, on renforcerait ce mécanisme avec des règles de protection d'environnement GitHub : approbation obligatoire par un ou plusieurs reviewers désignés, restriction aux branches protégées, délai d'attente configurable. On pourrait également ajouter une étape de revue de code obligatoire (pull request avec approbation) avant tout merge sur la branche main, garantissant qu'aucun changement n'atteint la production sans validation humaine.
