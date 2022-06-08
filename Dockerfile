FROM luizedsilva/compil-env:latest
COPY projects /home/projects
VOLUME /home
WORKDIR /home