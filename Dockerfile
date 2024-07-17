FROM node
EXPOSE 3000
RUN mkdir -m 777 -p /home/node/slack
WORKDIR /home/node/slack
ENTRYPOINT npm i && npm start