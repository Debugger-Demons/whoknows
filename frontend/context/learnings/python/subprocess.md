

The primary tool in Python's standard library for this (running cmds) is the **`subprocess`** module. 
   It offers several ways to interact with external commands, each with slightly different features. Here's a breakdown of the most common ones:

1.  **`subprocess.run()` (Recommended):**
    *   **What it is:** This is the modern, recommended function introduced in Python 3.5. It's designed to be a flexible replacement for older functions like `call` and `check_output`.
    *   **How it works:** It runs a command and waits for it to complete.
    *   **Key Features:**
        *   Can capture standard output (`stdout`) and standard error (`stderr`).
        *   Can check the return code and automatically raise an exception if the command fails (using `check=True`).
        *   Offers control over input, output, and error streams.
        *   Returns a `CompletedProcess` object containing information like the arguments, return code, stdout, and stderr.
    *   **Best for:** Most common scenarios where you need to run a command, potentially capture its output, and check if it succeeded. This is likely the best fit for running your `docker build` and `docker run` commands.

2.  **`subprocess.call()`:**
    *   **What it is:** An older function.
    *   **How it works:** Runs a command and waits for it to complete.
    *   **Key Features:**
        *   Returns the exit code of the command (typically 0 for success, non-zero for failure).
        *   Doesn't easily capture output.
        *   Doesn't automatically raise errors on failure.
    *   **Best for:** Simple cases where you only need to run a command and check its exit status, without needing its output. `run()` can do this too, and is generally preferred now.

3.  **`subprocess.check_call()`:**
    *   **What it is:** Similar to `call()`, but with built-in error checking.
    *   **How it works:** Runs a command and waits for it to complete.
    *   **Key Features:**
        *   Checks the return code. If it's non-zero (indicating an error), it raises a `CalledProcessError` exception.
        *   Doesn't easily capture output.
    *   **Best for:** Cases where you want the script to stop immediately if the command fails.

4.  **`subprocess.check_output()`:**
    *   **What it is:** Designed specifically for capturing the standard output of a command.
    *   **How it works:** Runs a command, waits for it to complete, and returns its standard output as a byte string.
    *   **Key Features:**
        *   Raises a `CalledProcessError` if the command fails.
        *   Returns the `stdout` directly.
    *   **Best for:** When the primary goal is to get the output of a command for further processing in Python.

5.  **`subprocess.Popen()`:**
    *   **What it is:** The most fundamental and flexible interface. `run()`, `call()`, etc., are essentially wrappers around `Popen`.
    *   **How it works:** Creates a new child process object. It doesn't necessarily wait for the command to complete immediately, allowing for more complex interactions (like non-blocking execution or managing input/output pipes continuously).
    *   **Best for:** Advanced use cases requiring fine-grained control over process creation and communication (e.g., running processes in the background, complex pipelines). It's more complex to use correctly than `run()`.

**In summary:** For your goal of running `docker build` and `docker run` commands within your `dev_docker.py` script, `subprocess.run()` is generally the most suitable and recommended approach due to its flexibility and ease of use for common tasks like running commands, checking success, and optionally capturing output.
