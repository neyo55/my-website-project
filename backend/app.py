import logging
from logging.handlers import RotatingFileHandler
from flask import Flask, request, render_template
import mysql.connector
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Initialize Flask app
app = Flask(__name__)

# Set the secret key for session management and CSRF protection
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')

# Ensure the logs directory exists and is writable
log_directory = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'logs')
if not os.path.exists(log_directory):
    os.makedirs(log_directory)

# Set up logging with rotation and use LOG_LEVEL from environment
log_file_path = os.path.join(log_directory, 'app.log')
handler = RotatingFileHandler(log_file_path, maxBytes=10240, backupCount=5)

# Get log level from environment, default to DEBUG if not set
log_level = os.getenv('LOG_LEVEL', 'DEBUG').upper()
logging.getLogger().setLevel(getattr(logging, log_level))

handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s:%(message)s'))
logging.getLogger().addHandler(handler)

# Check required environment variables
required_vars = ['DB_HOST', 'DB_USER', 'DB_PASSWORD', 'DB_NAME']
for var in required_vars:
    if not os.getenv(var):
        logging.error(f'Missing required environment variable: {var}')
        raise ValueError(f'Missing required environment variable: {var}')

# Configure database connection using environment variables
def get_db_connection():
    try:
        db = mysql.connector.connect(
            host=os.getenv('DB_HOST'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME')
        )
        logging.info('Database connection established successfully.')
        return db
    except mysql.connector.Error as err:
        logging.error(f'Error connecting to the database: {err}')
        raise

@app.route('/')
def index():
    try:
        return render_template('index.html')
    except Exception as e:
        logging.error(f'Error rendering index.html: {e}')
        return 'An error occurred while loading the page.', 500

@app.route('/submit', methods=['POST'])
def submit():
    db = get_db_connection()
    try:
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

        logging.info(f'Successfully inserted data for {name} into the database.')

        return render_template('thank_you.html')
    except mysql.connector.Error as db_err:
        logging.error(f'Database error: {db_err}')
        return 'A database error occurred.', 500
    except Exception as e:
        logging.error(f'Error in /submit route: {e}')
        return 'An error occurred while processing your request.', 500
    finally:
        if db.is_connected():
            db.close()
            logging.info('Database connection closed.')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=os.environ.get('FLASK_ENV') == 'development')
