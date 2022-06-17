# PHP benchmarks on Docker

This project aims to benchmark different PHP setups made with Docker:

- PHP + Apache (official image)
- PHP-FPM (official image) + nginx (official image)
- PHP (official image) + Laravel Octane
- PHP (official image, Alpine variant) + Laravel Octane


## How to run

```
python run.py
```


## Results

For the latest results, visit the [benchmarks][] provided by GitHub Actions.

As of 2022, running on Apple silicon, results are:

```
Running benchmark for target php-apache...
Build time: 36.692 s
Min request time out of 1000: 0.040 s
Max request time out of 1000: 0.303 s
---
Running benchmark for target php-fpm-nginx...
Build time: 33.414 s
Min request time out of 1000: 0.041 s
Max request time out of 1000: 0.123 s
---
Running benchmark for target php-fpm-nginx-custom...
Build time: 98.100 s
Min request time out of 1000: 0.004 s
Max request time out of 1000: 0.191 s
---
Running benchmark for target php-octane...
Build time: 146.454 s
Min request time out of 1000: 0.002 s
Max request time out of 1000: 0.073 s
---
Running benchmark for target php-octane-alpine...
Build time: 205.144 s
Min request time out of 1000: 0.002 s
Max request time out of 1000: 0.060 s
---
```

---
[benchmarks]: https://github.com/emyller/php-docker-benchmark/actions/workflows/benchmark.yml
