# 03 - Fiche tests

## Test automatisé GitHub Actions

- Workflow concerné : `01-ci.yml`
- Lien vers le run réussi : *(à compléter après le premier run — aller dans Actions > 01 - CI - Build et test > copier le lien du run réussi)*
- Ce qui est testé :
  - Présence des fichiers obligatoires (Dockerfile, compose.yml, site/index.html, site/version.json, docs/08-compte-rendu-final.md)
  - Validité de la syntaxe Docker Compose (`docker compose config`)
  - Construction de l'image Docker avec le SHA du commit
  - Test HTTP : le conteneur répond sur le port 8080, la page d'accueil contient "Catal-Log", le fichier version.json est accessible
- Résultat : *(à compléter — ex : "Tous les tests passent en ~45 secondes, run visible dans GitHub Actions")*

## Test local Docker ou Docker Compose

### Situation A - Test réalisé

Commandes utilisées :

```bash
# Build et test unitaire
docker build -t projet-cicd-nginx:local .
docker run --rm -p 8080:80 projet-cicd-nginx:local
# Vérification dans le navigateur : http://localhost:8080

# Test avec Docker Compose (build + tester automatique)
docker compose up --build
```

Résultat observé : *(à compléter après test — ex : "Le site s'affiche correctement sur localhost:8080, le service tester affiche le contenu HTML et le JSON de version puis se termine avec un code 0")*

## Tests complémentaires

- **Test de contenu** : `grep -i "Catal-Log"` dans la page HTML vérifie que le site est bien personnalisé et identifiable.
- **Test version.json** : `curl -fsS http://127.0.0.1:8080/version.json` vérifie que le fichier de métadonnées est accessible et correctement servi par Nginx.
- **Validation Compose** : `docker compose config` vérifie que la syntaxe YAML est valide et que les services sont correctement définis avant tout build.

## Simulation de scaling

Commandes utilisées :

```bash
docker compose up -d --scale web=2
docker compose ps
```

Résultat observé : *(à compléter après test — ex : "Deux instances du service web sont lancées. Docker Compose crée deux conteneurs projet-cicd-nginx-web-1 et projet-cicd-nginx-web-2, chacun exposant le port 80 sur le réseau interne cicd_net")*

## Limites de la simulation

- **Pas de load balancer** : Docker Compose ne fournit pas de répartiteur de charge. Les deux instances web ne sont pas accessibles de manière équilibrée depuis l'extérieur sans configuration supplémentaire (ex : un reverse proxy Nginx ou Traefik devant).
- **Pas de haute disponibilité** : si le moteur Docker tombe, tous les conteneurs s'arrêtent. Il n'y a pas de redistribution automatique sur un autre nœud.
- **Pas de supervision** : aucune métrique de performance, aucune alerte en cas de panne. Le healthcheck Docker est basique et ne remplace pas une solution comme Prometheus + Grafana.
- **Dépendance à l'environnement local** : le scaling fonctionne uniquement sur la machine où Docker est installé. En production, il faudrait un orchestrateur comme Kubernetes pour gérer le scaling sur un cluster de machines.
- **Pas de persistance de données** : dans ce projet le site est statique donc ce n'est pas un problème, mais en production il faudrait gérer les volumes, les bases de données et la cohérence des données entre instances.
