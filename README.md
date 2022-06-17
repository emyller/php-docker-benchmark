# PHP benchmarks on Docker

This project aims to benchmark different PHP setups made with Docker:

- PHP + Apache (official image)
- PHP-FPM (official image) + nginx (official image)
- PHP (official image) + Laravel Octane
- PHP (official image, Alpine variant) + Laravel Octane

## Results

For the latest results, visit the [benchmarks][] provided by GitHub Actions.

As of 2022, running on Apple silicon, results are:

```
Pulling external Docker images...
---
Running benchmark for target php-apache...
Build time: 31.189 s
Min request time out of 1000: 0.040 s
Max request time out of 1000: 0.109 s
---
Running benchmark for target php-fpm-nginx...
Build time: 30.730 s
Min request time out of 1000: 0.040 s
Max request time out of 1000: 0.138 s
---
Running benchmark for target php-octane...
Build time: 135.528 s
Min request time out of 1000: 0.002 s
Max request time out of 1000: 0.051 s
---
Running benchmark for target php-octane-alpine...
Build time: 180.497 s
Min request time out of 1000: 0.002 s
Max request time out of 1000: 0.050 s
---
```

---
[benchmarks]: https://github.com/emyller/php-docker-benchmark/actions/workflows/benchmark.yml
