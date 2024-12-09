FROM julia:latest

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY julia /app/julia/
WORKDIR /app/julia/
ENV JULIA_CPU_TARGET="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)"
RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.Pkg.precompile()'
# Build frontend
COPY vue /app/vue/
WORKDIR /app/vue

ENV VITE_ENV=production

RUN rm -rf node_modules package-lock.json
RUN npm install -g yarn
RUN yarn install
RUN yarn run build-only
RUN cp -r dist/* /var/www/html/

WORKDIR /app
COPY nginx.conf /etc/nginx/nginx.conf
COPY launch.sh /app/

RUN chmod +x launch.sh

EXPOSE 8000

CMD nginx && /app/launch.sh
