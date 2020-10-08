# Rapide setup Alfresco

Nécéssite d'avoir:
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)
* [Hyper-V](https://msdn.microsoft.com/fr-fr/library/mt169373(v=ws.11).aspx)

### Usage
1. Activer Hyper-V (Panneau de Configuration -> Programmes et fonctionnalités -> Activer ou désactiver des fonctionnalités Windows)
2. Ouvrir un terminal en mode administrateur (requis par Vagrant pour manipuler Hyper-V et SMB)
3. Créer un switch virtuel sous Hyper-V de type "reseau externe"
4. Cloner ce dépôt avec git
5. (Optionnel) Exporter la variable d'environnement `TMS_VAGRANT_SMB_PASSWORD` ayant pour valeur le mot de passe de votre compte utilisateur Windows.
   Ceci permettra d'eviter le prompt de saisie de vos identifiants pour le montage SMB.
6. Dans le fichier provision/provision.sh, ajuster les variables `PROJECT_REF` et `JAR_VERSION` pour pointer vers les dernières versions issues du CI build du projet `ged/Alfresco AIO`
7. Exporter la variable d'environnement `TMS_VAGRANT_GITLAB_TOKEN` utilisée par le Vagrantfile contenant votre "private token Gitlab"
8. Démarrer la VM:
    ```
    cd <path du clone>/vagrant-projets/alfresco && vagrant up
    ```
   Un message peut apparaitre la 1ère fois après installation des plugins indiquant de relancer la commande.
9. Si A la demande de selection du switch, utiliser le switch créé en 3.

A l'issu de cette commande, alfresco est installé dans la VM et est accessible via le nom de domaine `vagrant-debian8-alfresco` (une entrée a été créée dans le fichier hosts)

### Démarrage
Démarrer le service Alfresco dans la VM:
```
$ sudo service alfresco start
```

Alfresco Share est disponible via port forwarding à l'adresse: http://vagrant-debian8-alfresco:8080/share.


## Configuration
Le provisioning automatique d'Alfresco lui-même n'est pas en place, il faut le faire manuellement.
Ceci se fait en accédant à l'interface graphique Alfresco Share sous le user *admin*, mot de passe *admin*.

#### Users
1. Aller dans l'onglet "Admin Tools" (en-tête supérieur)
2. Aller dans le menu "Groups" et ajouter le groupe *44-000001* (Browse -> (+))
3. Aller dans le menu "Users" et entrer *%* dans "User Search"
4. Sélectionner le user *Mike Jackson* et l'éditer 
5. L'ajouter dans le groupe *44-000001*, changer son mot de passe (typiquement *mjackson*) pour facilité son debuggage, puis l'activer (décocher "Disable Account")
6. (Optionnel) Répéter l'opération pour le user *Alice Beecher* (mot de passe *abeecher*)

### Repository
1. Aller dans l'onglet "Repository" (en-tête supérieur)
2. Naviguer ensuite dans "Partagé" et créer le dossier *44-000001*

## Résumé URLs
* Alfresco CMIS Repository: http://vagrant-debian8-alfresco:8080/alfresco/api/-default-/public/cmis/versions/1.1/browser
* Alfresco API: http://vagrant-debian8-alfresco:8080/alfresco/api/-default-/public/alfresco/versions/1/
* Alfresco Share: http://vagrant-debian8-alfresco:8080/share
