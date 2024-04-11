# build 
FROM node:21.6.1-alpine AS build-stage

WORKDIR /usr/src/app

COPY . .

RUN npm install

RUN npm run build


# nginx
FROM nginx:1.24.0-alpine

COPY --from=build-stage /usr/src/app/dist /usr/share/nginx/html

COPY nginx/climate.conf /etc/nginx/conf.d/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]