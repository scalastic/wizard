# Utilisez une image de base Nginx
FROM ubuntu:20.04

RUN apt-get update -y

# Install Nginx
RUN apt-get install -y nginx

RUN rm -f /etc/nginx/sites-enabled/*
COPY jenkins.conf /etc/nginx/conf.d
#COPY gitlab.conf /etc/nginx/conf.d

# Exposez le port 80 pour HTTP
EXPOSE 80/tcp

# Commande de démarrage pour Nginx
CMD ["nginx", "-g", "daemon off;"]