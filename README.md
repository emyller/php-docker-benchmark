# PHP benchmarks on Docker

This project aims to benchmark different PHP setups made with Docker:

- PHP + Apache (official image)
- PHP-FPM (official image) + nginx (official image)
- PHP-FPM + nginx (custom image)
- PHP (official image) + Laravel Octane
- PHP (official image, Alpine variant) + Laravel Octane


## How to run

```
python run.py
```


## Method

- HTTP requests are made against a base Laravel app.
- Build time does not consider downloading base images.
- The five shortest and longest request times are displayed.


## Results

Results are collected in the [benchmarks][] provided by GitHub Actions. You can
also clone this repository and [run it yourself](#how-to-run).

```
Pulling external Docker images...
---
Running benchmark for target php-apache...
Build time: 45.802 s
Min request times out of 1000, in seconds: 0.072, 0.073, 0.074, 0.075, 0.076
Max request times out of 1000, in seconds: 0.136, 0.127, 0.115, 0.113, 0.112
---
Running benchmark for target php-fpm-nginx...
Build time: 36.921 s
Min request times out of 1000, in seconds: 0.078, 0.079, 0.08, 0.081, 0.082
Max request times out of 1000, in seconds: 0.121, 0.118, 0.112, 0.108, 0.106
---
Running benchmark for target php-fpm-nginx-custom...
Build time: 87.558 s
Min request times out of 1000, in seconds: 0.006, 0.007, 0.008, 0.009, 0.01
Max request times out of 1000, in seconds: 0.218, 0.022, 0.019, 0.018, 0.016
---
Running benchmark for target php-octane...
Build time: 236.887 s
Min request times out of 1000, in seconds: 0.002, 0.003, 0.004, 0.005, 0.006
Max request times out of 1000, in seconds: 0.118, 0.028, 0.024, 0.015, 0.013
---
Running benchmark for target php-octane-alpine...
Build time: 317.267 s
Min request times out of 1000, in seconds: 0.002, 0.003, 0.004, 0.005, 0.006
Max request times out of 1000, in seconds: 0.116, 0.024, 0.02, 0.012, 0.011
---
```

The results on an Apple M1 with 8 GB RAM are quite different:

```
Pulling external Docker images...
---
Running benchmark for target php-apache...
Build time: 31.803 s
Min request times out of 1000, in seconds: 0.04, 0.041, 0.042, 0.043, 0.044
Max request times out of 1000, in seconds: 0.12, 0.068, 0.067, 0.058, 0.056
---
Running benchmark for target php-fpm-nginx...
Build time: 30.753 s
Min request times out of 1000, in seconds: 0.04, 0.041, 0.042, 0.043, 0.044
Max request times out of 1000, in seconds: 0.122, 0.062, 0.057, 0.05, 0.048
---
Running benchmark for target php-fpm-nginx-custom...
Build time: 102.887 s
Min request times out of 1000, in seconds: 0.004, 0.005, 0.006, 0.007, 0.008
Max request times out of 1000, in seconds: 0.198, 0.016, 0.012, 0.01, 0.009
---
Running benchmark for target php-octane...
Build time: 134.901 s
Min request times out of 1000, in seconds: 0.002, 0.003, 0.004, 0.005, 0.006
Max request times out of 1000, in seconds: 0.049, 0.045, 0.013, 0.011, 0.01
---
Running benchmark for target php-octane-alpine...
Build time: 177.454 s
Min request times out of 1000, in seconds: 0.002, 0.003, 0.004, 0.005, 0.006
Max request times out of 1000, in seconds: 0.05, 0.01, 0.009, 0.008, 0.007
---
```

Numbers show that official PHP images with either Apache or Nginx don't perform
as well as a custom one. Laravel Octane offers a great improvement without the
need of an external HTTP server. Custom images take significantly longer to
build and also require maintaining of the components.

---
[benchmarks]: https://github.com/emyller/php-docker-benchmark/actions/workflows/benchmark.yml
