""" module for Makefile for local development """
import os
import sys

ENV_FILE_PATH = ".env"

def check_env():
    """ Check if the .env file exists and print the contents """
    if not os.path.exists(ENV_FILE_PATH):
        print(f"Error: {ENV_FILE_PATH} does not exist")
        sys.exit(1)

    with open(ENV_FILE_PATH, "r", encoding="utf-8") as file:
        for line in file:
            print(line.strip())

if __name__ == "__main__":
    check_env()
