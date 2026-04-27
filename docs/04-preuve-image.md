# 04 - Preuve image GHCR

## Image publiée

- Nom de l'image : `ghcr.io/yabquicode/asrc-cicd-pipeline`
- Tag principal : *(à compléter après le run de 02-publish-ghcr.yml — ex : sha-1e0ec87, latest)*
- Digest : *(à compléter — copier le digest SHA256 depuis le résumé du run ou depuis GHCR)*
- Lien GHCR : https://github.com/YabQuiCode/asrc-cicd-pipeline/pkgs/container/asrc-cicd-pipeline

## Explication

Le **tag** et le **digest** sont deux mécanismes complémentaires pour identifier une image Docker de manière fiable :

- Le **tag** (ex : `sha-1e0ec87` ou `latest`) est un identifiant lisible par l'humain. Il permet de retrouver rapidement une version spécifique. Cependant, un tag est mutable : on peut re-taguer une nouvelle image avec le même nom (c'est ce qui se passe avec `latest` à chaque push sur main).

- Le **digest** (ex : `sha256:abc123...`) est un identifiant immuable calculé à partir du contenu binaire exact de l'image. Deux images avec le même digest sont garanties identiques, bit pour bit. Le digest ne change jamais, même si le tag est réattribué.

Pour la **traçabilité**, le couple tag + digest permet de savoir exactement quelle version du code a produit quelle image, et de vérifier qu'une image n'a pas été altérée entre la publication et le déploiement.

Pour le **rollback**, si une nouvelle version pose problème, on peut redéployer l'image précédente en utilisant son digest exact : `docker pull ghcr.io/yabquicode/asrc-cicd-pipeline@sha256:abc123...`. Cela garantit de revenir à une version identique à celle qui fonctionnait, sans risque de récupérer une image modifiée entre-temps.
