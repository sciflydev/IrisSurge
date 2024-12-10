An example application using [Surge.jl](https://github.com/sciflydev/surge.jl) as a Julia backend.

Surge exposes state variables from the Julia process via websockets, enabling any client to retrieve these variables and update them to trigger routines.

The frontend is built in VueJS and uses the composable `useSurge` to sync values between the backend and the browser.

To run the app, go into each folder and install the dependencies as

```julia
cd julia
julia --project -e 'using Pkg; Pkg.instantiate()'

cd ../vue
yarn install # npm doesn't work, use yarn instead
cd ..
```

then, execute the launch script as

```sh
./launch.sh
```

and open a browser at the URL shown by the Vue process, eg, `http://localhost:5173`.

The provided Dockerfile will build a container that runs the backend and serves the frontend code via NGINX.
