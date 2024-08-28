import os

# Generate a 24-byte random secret key
secret_key = os.urandom(24).hex()
print(secret_key)




# This is a script to generate a random secret key for Flask's secret key, which is used for session management and CSRF protection.
# The script generates a 24-byte random secret key using the os.urandom() function, which generates cryptographically secure random bytes.
# The resulting secret key is then printed to the console.
# Note that this script should be used for development purposes only. In a production environment, you should use a more secure method to generate and manage your secret key.
# To use this script, save it to a file (e.g., generate_secret_key.py) and run it using the Python interpreter:
# This is the command to run the app 'python3 generate_secret_key.py' make sure you run it in the correct directory where this script is located.