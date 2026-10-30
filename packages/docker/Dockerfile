FROM node:22-alpine
LABEL org.opencontainers.image.title="imc-calculadora" \
      org.opencontainers.image.description="Calculadora IMC / BMI API with WHO classes and a bilingual (ES/EN) calculator page" \
      org.opencontainers.image.source="https://github.com/nbkdevs/imc-calculadora" \
      org.opencontainers.image.url="https://imccalculadora.app/" \
      org.opencontainers.image.documentation="https://imccalculadora.app/" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="IMC Calculadora"
WORKDIR /app
# Build context: packages/ (so the npm library is copied in, not downloaded)
COPY npm/package.json npm/README.md npm/LICENSE ./node_modules/imc-calculadora/
COPY npm/lib ./node_modules/imc-calculadora/lib
COPY docker/server.js ./
COPY docker/public ./public
ENV NODE_ENV=production PORT=8080
USER node
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
CMD ["node", "server.js"]
