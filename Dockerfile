# Estágio 1: Construção (Build)
FROM node:20-bookworm AS builder
# Instala o pnpm globalmente
RUN npm install -g pnpm

WORKDIR /app

# Copia os arquivos de manifesto de pacotes
COPY package.json pnpm-lock.yaml ./
# Instala as dependências
RUN pnpm install --frozen-lockfile

# Copia todo o resto do código-fonte
COPY . .

# Define a variável de ambiente para aumentar a memória do Node.js durante o build
ENV NODE_OPTIONS=--max-old-space-size=4096
# Executa o build
RUN pnpm run build

# Estágio 2: Produção (Imagem Final)
FROM node:20-bookworm AS runner
WORKDIR /app

# Define o ambiente para produção
ENV NODE_ENV=production

# Instala o pnpm para poder usar o comando 'wrangler'
RUN npm install -g pnpm

# Copia todos os arquivos do estágio de construção
COPY --from=builder /app .

...
# Expõe a porta correta que a aplicação usa
EXPOSE 3000

# O comando final e explícito para iniciar o servidor, ouvindo em todas as interfaces de rede
CMD ["sh", "-c", "bindings=$(./bindings.sh) && wrangler pages dev ./build/client --ip=0.0.0.0 --port=3000 $bindings"]
