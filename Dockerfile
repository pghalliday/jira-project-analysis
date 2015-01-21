FROM node:0.10.35
ADD . /code
WORKDIR /code
RUN npm install
ENV PATH=/code/node_modules/.bin:$PATH
CMD gulp start
