**Project structure**:

   ```
   my-web-project/
   ├── app.py
   ├── gunicorn_config.py
   ├── requirements.txt
   ├── .env
   ├── templates/
   |         └──index.html, thank_you.html
   ├── 
   ├── static/
   |         ├── css/-- style.css
   |         |
   |         └── js/-- script.js
   |
   ├── start_app.sh
   ├── create_service.sh
   |
   ├── .gitignore         
   |
   └──
   ```

## THE FILES 

# index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data Collection Form</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <script src="/static/js/script.js" defer></script>
</head>
<body>
    <div class="form-container">
        <h1>Submit Your Details</h1>
        <form id="dataForm" action="/submit" method="post">
            <div class="form-group">
                <label for="name">Name:</label>
                <input type="text" id="name" name="name" required>
            </div>
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
            </div>
            <div class="form-group">
                <label for="phone">Phone Number:</label>
                <input type="tel" id="phone" name="phone" pattern="^0[0-9]{10}$" title="Enter a valid phone number (e.g., 08012345678)" placeholder="e.g. 08012345678" required>
            </div>
            <div class="form-group">
                <label for="dob">Date of Birth:</label>
                <input type="date" id="dob" name="dob" required>
            </div>
            <div class="form-group">
                <label for="gender">Gender:</label>
                <select id="gender" name="gender">
                    <option value="male">Male</option>
                    <option value="female">Female</option>
                    <option value="other">Other</option>
                </select>
            </div>
            <div class="form-group">
                <label for="address">Address:</label>
                <textarea id="address" name="address" rows="3"></textarea>
            </div>
            <div class="form-group">
                <label for="agree">I agree to the terms and conditions</label>
                <input type="checkbox" id="agree" name="agree" required>
            </div>
            <button type="submit">Submit</button>
        </form>
    </div>
</body>
</html>

# thank_you.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thank You</title>
    <link rel="stylesheet" href="./style.css">
</head>
<body>
    <div class="form-container">
        <h1>Thank You for Submitting Your Details!</h1>
        <button onclick="location.href='/'">Home</button>
    </div>
</body>
</html>

# style.css
/* Existing CSS */

body {
    font-family: Arial, sans-serif;
    background-color: #f0f0f0;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
    padding: 10px; /* Added padding for small screens */
}

.form-container {
    background-color: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 400px; /* Ensure it doesn't exceed 400px */
    box-sizing: border-box; /* Ensure padding and border are included in the width */
    overflow: hidden; /* Prevent content from overflowing */
}

.form-container h1 {
    margin-bottom: 20px;
    text-align: center;
    font-size: 1.2em; /* Adjust font size */
    color: #333;
    word-wrap: break-word; /* Allow long words to be broken and wrap to the next line */
    overflow: hidden; /* Ensure text does not overflow the container */
    white-space: nowrap; /* Prevent wrapping of text */
    text-overflow: ellipsis; /* Add ellipsis if the text overflows */
}

h1 {
    margin-bottom: 20px;
    text-align: center;
    font-size: 2em; /* Adjust font size */
    color: #333;
    word-wrap: break-word; /* Allow long words to be broken and wrap to the next line */
    overflow: hidden; /* Ensure text does not overflow the container */
    white-space: nowrap; /* Prevent wrapping of text */
    text-overflow: ellipsis; /* Add ellipsis if the text overflows */
}

.form-group {
    margin-bottom: 15px;
}

label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
}

input, select, textarea {
    width: 100%;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

button {
    width: 100%;
    padding: 10px;
    background-color: #007BFF;
    border: none;
    border-radius: 4px;
    color: white;
    font-size: 16px;
    cursor: pointer;
    transition: background-color 0.3s;
}

button:hover {
    background-color: #0056b3;
}

#agree {
    width: auto;
}

/* Responsive Design */
@media only screen and (max-width: 768px) {
    .form-container {
        width: 90%; /* Make form container more flexible */
        padding: 15px; /* Adjust padding */
    }

    h1 {
        font-size: 1.5em; /* Smaller font size for smaller screens */
    }

    input, select, textarea, button {
        font-size: 14px; /* Adjust font size for inputs and button */
        padding: 8px; /* Adjust padding */
    }
}

@media only screen and (max-width: 480px) {
    .form-container {
        width: 100%;
        padding: 10px; /* Further adjust padding */
    }

    h1 {
        font-size: 1.2em; /* Further reduce font size for very small screens */
        word-wrap: break-word; /* Ensure long words wrap correctly */
    }

    input, select, textarea, button {
        font-size: 12px; /* Further adjust font size */
        padding: 6px; /* Further adjust padding */
    }
}

# script.js
document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('dataForm');

    form.addEventListener('submit', (event) => {
        const phone = document.getElementById('phone').value;
        const phonePattern = /^0[0-9]{10}$/;

        if (!phonePattern.test(phone)) {
            alert('Please enter a valid 10-digit phone number.');
            event.preventDefault(); // Prevent form submission
        }

        const agree = document.getElementById('agree').checked;
        if (!agree) {
            alert('You must agree to the terms and conditions.');
            event.preventDefault(); // Prevent form submission
        }
    });
});

# app.py
rom flask import Flask, request, render_template
import mysql.connector
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

# Configure database connection using environment variables
db = mysql.connector.connect(
    host=os.getenv('DB_HOST'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    database=os.getenv('DB_NAME')
)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/submit', methods=['POST'])
def submit():
    name = request.form['name']
    email = request.form['email']
    phone = request.form['phone']
    dob = request.form['dob']
    gender = request.form['gender']
    address = request.form['address']

    # Insert data into the database
    cursor = db.cursor()
    cursor.execute(
        "INSERT INTO users (name, email, phone, dob, gender, address) VALUES (%s, %s, %s, %s, %s, %s)",
        (name, email, phone, dob, gender, address)
    )
    db.commit()
    cursor.close()

    return render_template('thank_you.html')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)

# gunicorn_config.py
bind = "127.0.0.1:5000"
workers = 2  # Adjust based on your machine's CPU cores
timeout = 120
loglevel = "debug"
errorlog = "-"
accesslog = "-"

# create_service.sh
#!/bin/bash

# Variables
SERVICE_NAME="my_web_app"
PROJECT_DIR="$HOME/my-website-project"
VENV_PATH="$PROJECT_DIR/.venv"
USER_NAME=$(whoami)
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# Create the system service file
echo "Creating system service file for $SERVICE_NAME..."

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Gunicorn instance to serve my web app
After=network.target

[Service]
User=$USER_NAME
Group=www-data
WorkingDirectory=$PROJECT_DIR
Environment=\"PATH=$VENV_PATH/bin\"
ExecStart=$VENV_PATH/bin/gunicorn -c $PROJECT_DIR/gunicorn_config.py app:app

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the service
echo "Enabling and starting the $SERVICE_NAME service..."
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

# Check the status of the service
echo "Checking the status of the $SERVICE_NAME service..."
sudo systemctl status $SERVICE_NAME

# requirements.txt
flask
mysql-connector-python
python-dotenv
gunicorn

# start_app.sh
#!/bin/bash

# Set the project directory and virtual environment path
PROJECT_DIR="$HOME/my-website-project"
VENV_PATH="$PROJECT_DIR/.venv"

# Function to check and install Python if not already installed
install_python() {
    if ! command -v python3 &> /dev/null; then
        echo "Python3 is not installed. Installing Python3..."
        sudo apt update
        sudo apt install -y python3 python3-venv python3-pip
    else
        echo "Python3 is already installed."
    fi

    if ! command -v python &> /dev/null; then
        echo "Python is not installed. Creating a symlink to Python3..."
        sudo ln -s /usr/bin/python3 /usr/bin/python
    else
        echo "Python is already installed."
    fi
}

# Check and install Python if necessary
install_python

# Check if the virtual environment directory exists
if [[ ! -d "$VENV_PATH" ]]; then
    echo "Virtual environment not found. Creating a new one..."
    python3 -m venv "$VENV_PATH"
fi

# Activate the virtual environment
echo "Activating the virtual environment..."
if [ -f "$VENV_PATH/bin/activate" ]; then
    # Try to source the virtual environment using 'source'
    if source "$VENV_PATH/bin/activate"; then
        echo "Virtual environment activated."
    else
        echo "Failed to activate the virtual environment."
        exit 1
    fi
else
    echo "Virtual environment activation script not found."
    exit 1
fi

# Install requirements
echo "Installing requirements from requirements.txt..."
pip install --upgrade pip
pip install -r "$PROJECT_DIR/requirements.txt"

# Print confirmation that the requirements are installed
if [[ $? -eq 0 ]]; then
    echo "Requirements installed successfully."
else
    echo "Failed to install requirements."
    exit 1
fi

# Run Gunicorn
echo "Starting Gunicorn..."
exec gunicorn -c "$PROJECT_DIR/gunicorn_config.py" app:app


# .env
DB_USER=neyo55
DB_PASSWORD=Neyo@55
DB_NAME=neyo_db
DB_HOST=46.101.11.165

# .gitignore
.env



