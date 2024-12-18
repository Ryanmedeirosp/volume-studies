FROM debian:12.8
RUN apt-get update -y && apt-get install -y \
    nginx \
    rpcbind\
    wget && \
    apt-get clean

EXPOSE 80

#config nginx
COPY ./nginx /etc/nginx/sites-enabled/default 
WORKDIR /var/www/html


#Config wordpress
RUN wget https://wordpress.org/latest.tar.gz && tar -xvzf latest.tar.gz
RUN chown -R www-data: /var/www/html/ && chmod -R 755 /var/www/html/
COPY ./wp-config.php /var/www/html/wordpress/wp-config.php


RUN mkdir /run/sendsigs.omit.d

CMD ["bash", "-c", "rpcbind && nginx -g 'daemon off;'"]


## comando para run
#  docker run -it -p 80:80 --network wordpress-net --name nginx --privileged  nginx

#docker run -d --name nginx --network wordpress-net -v wordpress_data:/var/www/html -p 80:80 nginx:latest