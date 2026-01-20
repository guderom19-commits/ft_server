# ft_server — Debian Buster (Nginx + PHP + WordPress + phpMyAdmin + MariaDB)

Ce projet met en place un serveur web dans **un seul conteneur Docker** basé sur **Debian Buster**.  
Le conteneur lance plusieurs services en même temps (Nginx / PHP-FPM / MariaDB) et sert :

- **WordPress** sur `/wordpress/`
- **phpMyAdmin** sur `/phpmyadmin/`

Bonus : support **HTTPS (SSL autosigné)**.

---

## Prérequis

- Docker Desktop installé
- Un terminal (CMD sur Windows suffit)

---

## Build

Dans le dossier du projet :

```bash
docker build -t ft_server .
```

---

## Run

### HTTP (port 8080)

```bash
docker rm -f ft_server
docker run -d -p 8080:80 -e AUTOINDEX=off --name ft_server ft_server
```

Ouvrir :
- http://127.0.0.1:8080/

---

### HTTPS (bonus) (port 8443)

```bash
docker rm -f ft_server
docker run -d -p 8080:80 -p 8443:443 -e AUTOINDEX=off --name ft_server ft_server
```

Ouvrir :
- https://127.0.0.1:8443/

    Le certificat est autosigné, donc le navigateur affichera un avertissement de sécurité (normal).

---

## Accès aux services

- Accueil :  
  http://127.0.0.1:8080/

- WordPress :  
  http://127.0.0.1:8080/wordpress/

- phpMyAdmin :  
  http://127.0.0.1:8080/phpmyadmin/

---

## Base de données (MariaDB)

La base est initialisée automatiquement au démarrage du conteneur.

- Database : `wordpress`
- User : `wp_user`
- Password : `wp_pass`

---

## Autoindex (ENV)

L’autoindex Nginx peut être activé/désactivé avec la variable d’environnement `AUTOINDEX`.

### Autoindex OFF
```bash
docker rm -f ft_server
docker run -d -p 8080:80 -e AUTOINDEX=off --name ft_server ft_server
```

### Autoindex ON
```bash
docker rm -f ft_server
docker run -d -p 8080:80 -e AUTOINDEX=on --name ft_server ft_server
```

---

## Commandes utiles

Voir les conteneurs actifs :
```bash
docker ps
```

Logs du conteneur :
```bash
docker logs ft_server
```

Stop / supprimer le conteneur :
```bash
docker rm -f ft_server
```

---

## Notes

- Tous les services tournent dans **un seul conteneur** via **Supervisor**.
- Nginx redirige vers les bons services selon l’URL (`/wordpress/` et `/phpmyadmin/`).
- Le projet est livré via un dépôt **GitHub public**.
