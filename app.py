from flask import Flask, request, render_template
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















# from flask import Flask, request, render_template
# import mysql.connector
# from dotenv import load_dotenv
# import os

# # Load environment variables from .env file
# load_dotenv()

# app = Flask(__name__)

# # Configure database connection using environment variables
# db = mysql.connector.connect(
#     host=os.getenv('DB_HOST'),
#     user=os.getenv('DB_USER'),
#     password=os.getenv('DB_PASSWORD'),
#     database=os.getenv('DB_NAME')
# )

# @app.route('/')
# def index():
#     return render_template('index.html')

# @app.route('/submit', methods=['POST'])
# def submit():
#     name = request.form['name']
#     email = request.form['email']
#     phone = request.form['phone']
#     dob = request.form['dob']
#     gender = request.form['gender']
#     address = request.form['address']

#     # Insert data into the database
#     cursor = db.cursor()
#     cursor.execute(
#         "INSERT INTO users (name, email, phone, dob, gender, address) VALUES (%s, %s, %s, %s, %s, %s)",
#         (name, email, phone, dob, gender, address)
#     )
#     db.commit()
#     cursor.close()

#     return "Thank you for submitting your details!"

# if __name__ == "__main__":
#     app.run(host='0.0.0.0', port=5000, debug=True)
