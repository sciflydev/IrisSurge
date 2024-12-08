FROM julia:latest

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs 

COPY . /app
WORKDIR /app/julia/
ENV JULIA_CPU_TARGET="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)"
RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.Pkg.precompile()'
# Build frontend
WORKDIR /app/vue
RUN rm -rf node_modules package-lock.json
RUN npm install -g yarn
RUN yarn install
RUN yarn run build-only

WORKDIR /app

RUN chmod +x launch.sh

EXPOSE 8000 8081

CMD ["/app/launch.sh"]
