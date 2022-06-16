import shlex
import socket
import subprocess
import time
import urllib.request

TIMEOUT = 5


def time_request(url):
    """
    Make a HTTP GET request to the given URL
    """
    start = time.time()
    response = urllib.request.urlopen(url)
    end = time.time()
    delta = end - start
    return delta


def wait_for_port(host, port):
    """
    Wait until a port is ready to accept connections
    """
    start = time.perf_counter()
    while True:
        try:
            with socket.create_connection((host, port), timeout=TIMEOUT):
                break
        except OSError as exc:
            time.sleep(0.01)
            now = time.perf_counter()
            if now - start >= TIMEOUT:
                raise TimeoutError('App not responding') from exc


def benchmark_http(target, url):
    """
    Run benchmarks against a target
    """
    # Start the container
    run_cmd = f'docker-compose run -d --rm --service-ports {target}'
    container_id = subprocess.check_output(shlex.split(run_cmd)).decode()
    time.sleep(3)  # Let it warm up

    try:  # Wait for the server to be ready
        print(f'Waiting on {target}...')
        wait_for_port('localhost', 8000)

    except TimeoutError:  # Eventually die of a timeout
        print(f'Failed to reach {target}.')
        raise

    else:  # Run benchmarks
        print(f'Running benchmark on {target}...')
        times = []
        for _ in range(100):
            delta = time_request(url)
            times.append(delta)
        return min(times), max(times)

    finally:  # Terminate the server
        print(f'Terminating {target} server...')
        subprocess.check_output(shlex.split(f'docker kill {container_id}'))


# Run all benchmarks
for target in [
    'php-apache',
    'php-octane',
]: print(target, benchmark_http(target, 'http://localhost:8000'))
