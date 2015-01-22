FROM node:0.10.35
ADD . /code
WORKDIR /code
RUN ./docker-scripts/create-user.sh jts
ENV PATH=/code/node_modules/.bin:$PATH
RUN chown -R jts:jts /code
USER jts
RUN npm install
CMD gulp start
