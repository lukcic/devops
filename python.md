# python

## Concurrency vs parallelism

### `Concurrency`

Interleaving execution of tasks within one CPU thread which looks like they work simultaneously.
Concurrency is about interruptibility.

```py
from concurrent.futures import ThreadPoolExecutor

if __name__ == '__main_':
    links = get_links())
    print(f"Total pages: {len(links)}")
    start_time = time.time()

    with ThreadPoolExecutor(max_workers=16) as executor:
        executor.map(fetch, links)

    duration = time.time() - start_time
    print(f"Downloaded {len(links)} links in {duration} seconds")
```

### `Parallelism`

Running (at the exact same time) multiple tasks using dedicated CPU threads for each task. Parallelism
is about independentability.

```py
from multiprocessing import Pool, cpu_count

if __name__ == '__main__':
    links = get_links()
    print(f"Total pages: {len(links)}")
    start_time = time.time()

    with Pool(cpu_count()) as p:
        p.map(fetch, links)

    duration = time.time() - start_time
    print(f"Downloaded {len(links)} links in {duration} seconds")
```
