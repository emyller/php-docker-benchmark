import contextlib
import dataclasses
import heapq
import shlex
import subprocess
import threading
import time
import urllib.request


def run(cmd: str, check=False):
    """
    Run a command and wait for it to finish
    """
    cmd_args = shlex.split(cmd)  # Split string in shell args

    process = subprocess.run(  # Run the command
        cmd_args,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    if not check:  # We're done if not checking for return code
        return

    try:  # Raise if command wasn't successful
        process.check_returncode()
    except subprocess.CalledProcessError:
        print(process.stdout.decode())
        raise


@dataclasses.dataclass
class Benchmark:
    """
    A benchmark of a Docker case
    """

    target: str
    url: str = 'http://localhost:8000'
    service_name: str = None
    requests_amount: int = 1000

    def _raise_timeout(self):
        raise TimeoutError

    @contextlib.contextmanager
    def timer(self, timeout: int):
        """
        A context manager to time code
        """
        alarm = threading.Timer(timeout, self._raise_timeout)
        alarm.start()
        times = {}
        times['start'] = start = time.perf_counter()
        try:
            yield times  # Let the context'ed code be executed
        finally:
            alarm.cancel()  # Cancel the timeout
        times['end'] = end = time.perf_counter()
        times['elapsed'] = end - start

    def measure_build(self) -> dict:
        """
        Measure Docker image built time
        """
        service = self.service_name or self.target
        with self.timer(600) as result:  # 10 minutes timeout
            run(f'docker-compose build --no-cache {service}', check=True)
        return result['elapsed']

    def measure_requests(self):
        """
        Run Docker services and measure requests time
        """
        # Start the service
        run(f'docker-compose run -d --rm --service-ports {self.target}', check=True)
        time.sleep(3)  # Some warmup time

        # Request elapsed times
        times = set()

        try:  # Measure requests
            for _ in range(self.requests_amount):
                with self.timer(5) as result:  # 5 seconds timeout
                    response = urllib.request.urlopen(self.url)
                assert response.status == 200

                # Record elapsed time
                elapsed = round(result['elapsed'], 3)
                times.add(elapsed)

        finally:  # Stop all containers
            run('docker-compose down')

        # Calculate shortest and longest times
        shortest_times = heapq.nsmallest(5, times)
        longest_times = heapq.nlargest(5, times)
        return shortest_times, longest_times


if __name__ == '__main__':
    # Pull external images
    print('Pulling external Docker images...')
    run('docker-compose pull')
    print('---')

    # Run all benchmarks
    for benchmark in [
        Benchmark(target='php-apache'),
        Benchmark(target='php-fpm-nginx', service_name='php-fpm'),
        Benchmark(target='php-fpm-nginx-custom'),
        Benchmark(target='php-octane'),
        Benchmark(target='php-octane-alpine'),
    ]:
        print(f'Running benchmark for target {benchmark.target}...')

        # Build
        build_time = benchmark.measure_build()
        print(f'Build time: {build_time:.3f} s')

        # Requests
        min_request_times, max_request_times = benchmark.measure_requests()
        print(f'Min request times out of {benchmark.requests_amount}, in seconds: ' + ', '.join(map(str, min_request_times)))
        print(f'Max request times out of {benchmark.requests_amount}, in seconds: ' + ', '.join(map(str, max_request_times)))
        print('---')
