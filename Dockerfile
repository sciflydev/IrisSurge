FROM node:20 AS vue-builder
COPY vue /app/vue/
WORKDIR /app/vue
ENV VITE_ENV=production
RUN yarn install && \
    yarn run build-only

FROM julia:latest
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY julia /app/julia/
WORKDIR /app/julia/
ENV JULIA_CPU_TARGET="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)"
RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'


# Copy Vue.js build artifacts from vue-builder
COPY --from=vue-builder /app/vue/dist /var/www/html/

# Copy configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY launch.sh /app/
RUN chmod +x /app/launch.sh

EXPOSE 8000

ENV VITE_ENV=production

CMD nginx && /app/launch.sh
