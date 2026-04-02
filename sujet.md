Pour cette mise en production, je vais vous proposer :

de prendre un collab sur le net
de le basculer dans un container docker
de le cacher sous la forme d'un service derrière un frontal dans un autre container
Si vous lisez il y a de nombreuses ressources de taille non négligeable qui doivent être disponible avant la séance et je vous demanderais donc de remplir les prérequis avant de venir en TD

Prérequis LINUX
Le premier prérequis n'est pas innocent : linux et ubuntu c'est très bien. En 2023, il y avait deux solutions de virtualisations opérationnelles : dualboot et vmware. Virtualbox ne marchait pas.
En 2024, j'ai fait un effort de tester VMWare workstation 17.6 Pro et WSL2.
+ VMWare workstation 17.6 Pro : quand vous l'aurez installé (en octobre 2024 fallait créer des fake groups Administrator et je ne sais plus quoi de plus pour que le contrôle d'installation marche sur un ordinateur en Français (Allemand, etc selon le web), utilisez un docker engine de préférence.
+ WSL2 : quand vous aurez configuré Windows pour la bonne virtualisation, image, etc.... vous aurez un WSL ubuntu-24.04 qui est parfait mais sans docker. Vous installez Docker Desktop qui s'intègre windows et WSL2 et ça passe tout seul.
En 2026, j'ai toujours mon VMWare donc je ferais avec lui, ma tour est en WSL2 et semblait toujours coopérer, mais je n'ai pas fait de mise à jour depuis...
Prérequis application
Les prérequis pour faire une mise en production sont nombreux : curl, docker, maven, etc... Par contre, pas d'IDE, juste un éditeur de texte normal.
 
Pour précharger les besoins logiciels, j'ai fait un script qui est à la racine du zip ci-dessous que vous allez télécharger et dézippez. Moi je l'ai déposé dans 'dossier personnel'  de mon compte préféré sur la machine linux. Il y a un ReadMe vous pouvez le consulter.

Ce script essaie de lancer les commandes nécessaires et de valider les installations. Si les commandes ne sont pas disponibles un sudo apt install XXX est fait automatiquement. Attention, il y en a plein mais seul le premier demande un mot de passe après les installations s'enchainent. SI docker n'est pas installé il faudra vous attendre à devoir rebooter la machine, la solution avec un systemctl pour relancer le docker n'a pas marché chez moi. 

Pour lancer la commande c'est ./preload -e ou -d .

Avec -e vous forcerez le téléchargement de docker engine dernier cri et une désinstallation des anciens dockers. Si vous faites -f c'est un docker deprecated qui est préféré (cela vous permet de ne pas forcer docker engine si vous souhaitez conserver votre vieux docker).

J'ai commencé avec le -d pour préserver mon existant mais après plusieurs installations dans diverses machines, le docker engine sur linux ou le docker desktop sur windows avec intégration WSL2 c'est le top. Peut être que WSL2 est même 'plus simple' .... jusqu'à ce qu'il crash le portable.

Attention quand même d'avoir une bonne liaison réseau et de la place sur le disque car vous allez télécharger au moins 4 G d'images, de bibliothèques springboot, de machins, des trucs et des bidules.

J'étais sur une machine qui offrait, dans le noyaux le support docker, aujourd'hui cela a tendance a disparaître au profit de podman, mais j'ai décidé de braver l'histoire.