#FROM golang:1.17-alpine AS gcsfuse
#RUN apk add --no-cache git
#ENV GOPATH /go
#RUN go install github.com/googlecloudplatform/gcsfuse@latest

FROM node:16.14-alpine AS builder

RUN mkdir -p /usr/src/trudesk
WORKDIR /usr/src/trudesk

COPY . /usr/src/trudesk

RUN apk add --no-cache --update bash make gcc g++ python3
RUN yarn plugin import workspace-tools
RUN yarn workspaces focus --all --production
RUN cp -R node_modules prod_node_modules
RUN yarn install
RUN yarn build
RUN rm -rf node_modules && mv prod_node_modules node_modules
RUN rm -rf .yarn/cache

FROM node:16.14-alpine
WORKDIR /usr/src/trudesk
RUN apk add --no-cache ca-certificates bash mongodb-tools && rm -rf /tmp/*
COPY --from=builder /usr/src/trudesk .
COPY ./public/img/defaultProfile.jpg /usr/src/trudesk/public/uploads/users/defaultProfile.jpg
#COPY --from=gcsfuse /go/bin/gcsfuse /usr/local/bin

EXPOSE 8118

RUN mkdir -p /usr/src/trudesk/public/uploads/users

CMD ["node", "/usr/src/trudesk/runner.js"]

#CMD [ "/bin/bash", "/usr/src/trudesk/startup.sh" ]
