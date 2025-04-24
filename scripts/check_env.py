""" module for Makefile for local development """
import os
import sys

ENV_FILE_PATH = ".env"
REQUIRED_FILES = [
            "./database/whoknows.db",
            ".env"
]

def check_env():
    """ Check if the .env file exists and print the contents """
    
    # check for required files
    check_required_files()

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

def check_required_files():
    """ Check if required files exist """
    current_dir = os.getcwd()
    print(f"Current directory: {current_dir}")
    for file in REQUIRED_FILES:
        if not os.path.exists(file):
            print(f"Error: {file} does not exist")
            print("Please create the required files")
            sys.exit(1)
        else:
            print(f"{file} exists")

def cp_env():
    """ get OS then proper CP command execution (Windows/Linux) """
    if sys.platform == "win32":
        os.system(f"copy .env.development {ENV_FILE_PATH}")
    else: # Linux
        os.system(f"cp .env.development {ENV_FILE_PATH}")

if __name__ == "__main__":
    check_env()
