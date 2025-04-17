# Python Async Concepts Explained

This document explains key concepts related to asynchronous programming in Python.

## Table of Contents
- [Python Async Concepts Explained](#python-async-concepts-explained)
  - [Table of Contents](#table-of-contents)
  - [Term List](#term-list)
  - [`async` / `await`](#async--await)
  - [`asyncio`](#asyncio)
  - [`subprocess.run`](#subprocessrun)

## Term List

*   `async` / `await`
*   `asyncio`
*   `subprocess.run`

---

## `async` / `await`

*   **Definition:** `async` and `await` are Python keywords introduced in Python 3.5 that provide a syntax for defining and working with asynchronous code. `async def` defines an asynchronous function (a coroutine), and `await` pauses the execution of the coroutine until the awaited asynchronous operation completes.

*   **Explanation:** Asynchronous programming allows code to perform other tasks while waiting for long-running operations (like I/O, network requests, or delays) to finish. Instead of blocking the entire thread, `await` yields control back to the event loop, which can run other tasks. When the awaited operation is done, the event loop resumes the paused coroutine. This enables concurrency (handling multiple operations seemingly at the same time) within a single thread.

*   **Example:**

    ```python
    import asyncio
    import time

    async def say_after(delay, what):
        await asyncio.sleep(delay) # Non-blocking sleep
        print(f"{time.strftime('%X')} - {what}")

    async def main():
        print(f"Started at {time.strftime('%X')}")
        await say_after(1, 'hello')
        await say_after(2, 'world')
        print(f"Finished at {time.strftime('%X')}")

    # To run the async main function
    # asyncio.run(main()) 
    # Output will show a 1s delay, then 'hello', then a 2s delay, then 'world'
    ```

---

## `asyncio`

*   **Definition:** `asyncio` is Python's built-in library for writing concurrent code using the `async`/`await` syntax. It provides the underlying infrastructure, including an event loop, for managing and executing asynchronous tasks.

*   **Explanation:** `asyncio` is the foundation for async Python. It provides:
    *   **Event Loop:** The core of asyncio. It runs asynchronous tasks and callbacks, performs network IO, and runs subprocesses.
    *   **Coroutines:** Functions defined with `async def`. They are the primary way to define asynchronous operations.
    *   **Tasks:** `asyncio` "wrappers" for coroutines that schedule them to run on the event loop soon.
    *   **Futures:** Objects representing the eventual result of an asynchronous operation.
    *   **Transports and Protocols:** APIs for implementing network protocols (like TCP, UDP).
    *   **Synchronization Primitives:** Async-compatible versions of locks, events, queues, etc. (`asyncio.Lock`).
    *   **Subprocess Management:** Asynchronous ways to run and manage child processes (`asyncio.create_subprocess_shell`, `asyncio.create_subprocess_exec`).

*   **Example (Running tasks concurrently):**

    ```python
    import asyncio
    import time

    async def say_after(delay, what):
        await asyncio.sleep(delay)
        print(f"{time.strftime('%X')} - {what}")

    async def main():
        task1 = asyncio.create_task(say_after(1, 'hello'))
        task2 = asyncio.create_task(say_after(2, 'world'))

        print(f"Started at {time.strftime('%X')}")
        # Wait for both tasks to complete
        await task1
        await task2
        print(f"Finished at {time.strftime('%X')}")

    # To run the async main function
    # asyncio.run(main()) 
    # Output will show 'hello' after ~1s and 'world' after ~2s from the start.
    # The total time will be ~2s, not 3s, because they run concurrently.
    ```

---

## `subprocess.run`

*   **Definition:** A function from Python's standard `subprocess` module used to run external commands in a subprocess.

*   **Explanation (in terms of async and processes):** `subprocess.run` is fundamentally **synchronous** and **blocking**. When you call `subprocess.run`, your Python script's execution *stops* and waits for the external command to complete before proceeding to the next line in your script. This is the opposite of asynchronous behavior.

    While it runs the command in a separate *process*, it blocks the *calling thread* within your Python script. If you need to run an external command without blocking the main thread (especially within an `asyncio` application), you should use `asyncio`'s own subprocess functions:
    *   `asyncio.create_subprocess_shell`: Runs a command using the system's shell (like `subprocess.run(..., shell=True)`). Generally less secure if command includes user input.
    *   `asyncio.create_subprocess_exec`: Runs an executable directly, passing arguments as a sequence (like `subprocess.run(..., shell=False)`). More secure.

    These `asyncio` functions return `Process` objects, and you typically use `await process.wait()` or `await process.communicate()` to asynchronously wait for the subprocess to finish.

*   **Example (Contrasting Blocking vs. Async):**

    ```python
    import subprocess
    import asyncio
    import time

    # --- Blocking Example ---
    def blocking_subprocess():
        print(f"{time.strftime('%X')} - Running blocking command...")
        # This blocks for 3 seconds
        result = subprocess.run(["sleep", "3"], capture_output=True, text=True) 
        print(f"{time.strftime('%X')} - Blocking command finished.")
        # print(f"Result code: {result.returncode}")

    # --- Async Example ---
    async def async_subprocess():
        print(f"{time.strftime('%X')} - Running async command...")
        # This starts the command but doesn't block the event loop
        process = await asyncio.create_subprocess_exec("sleep", "3")
        print(f"{time.strftime('%X')} - Async command started, can do other things...")
        # await asyncio.sleep(1) # Example: do other work here
        # print(f"{time.strftime('%X')} - Did other work.")
        return_code = await process.wait() # Asynchronously wait for completion
        print(f"{time.strftime('%X')} - Async command finished.")
        # print(f"Result code: {return_code}")

    # --- Running them ---
    # print("--- Running Blocking ---")
    # blocking_subprocess() 
    # print("\n--- Running Async ---")
    # asyncio.run(async_subprocess()) 
    ``` 