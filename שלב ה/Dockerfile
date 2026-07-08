FROM node:20-bookworm-slim

WORKDIR /app

COPY package.json ./
COPY .npmrc ./

RUN npm install --legacy-peer-deps --no-audit --no-fund --verbose

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
