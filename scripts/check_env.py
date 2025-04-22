""" module for Makefile for local development """
import os
import sys

ENV_FILE_PATH = ".env"

def check_env():
    """ Check if the .env file exists and print the contents """
    if not os.path.exists(ENV_FILE_PATH):
        print(f"Error: {ENV_FILE_PATH} does not exist")
        print("Please create a .env file in the root directory")
        print("press Enter to create (cp .env.development .env) [y]/n)")
        if input() != "n":
            os.system("cd ..")
            cp_env()
            sys.exit(0)
        else:
            sys.exit(1)

    with open(ENV_FILE_PATH, "r", encoding="utf-8") as file:
        for line in file:
            print(line.strip())

def cp_env():
    """ get OS then proper CP command execution (Windows/Linux) """
    if sys.platform == "win32":
        os.system(f"copy .env.development {ENV_FILE_PATH}")
    else: # Linux
        os.system(f"cp .env.development {ENV_FILE_PATH}")

if __name__ == "__main__":
    check_env()
