# Utilisez une image de base Nginx
FROM nginx

COPY jenkins.conf /etc/nginx/conf.d

# Exposez le port 80 pour HTTP
EXPOSE 80/tcp

# Commande de démarrage pour Nginx
CMD ["nginx", "-g", "daemon off;"]