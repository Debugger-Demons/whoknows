# Adding Users to a VM

This guide explains how to add users and SSH keys to a Virtual Machine (VM) via Azure.

## Step 1: Open "Reset Password"

1. Go to the VM in the Azure portal.
2. Click on the search box on the left and type **"Reset Password"**.
3. Select **"Reset password"** from the menu.

## Step 2: Add SSH Public Key

Once you are on the **"Reset password"** page:

1. Set **Mode** to **"Add SSH public key"**.
2. Enter a new username for the user to be added.
3. Insert the user's **public SSH key**.
4. Make sure to use **ssh-ed25519** for encryption, as RSA did not work for us.

## Important

- **Only** `ed25519` and **not** RSA, as the RSA format is not supported in our case.
- The username must be unique if it is a new user.
- Once created, the user can log in via SSH using the added key.

This ensures that multiple users can access the server via SSH without sharing passwords.
