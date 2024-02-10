# app.py

from flask import Flask, render_template, request, jsonify
from flask_cors import CORS

import subprocess
import csv

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

@app.route('/')
def index():
    return render_template('scrapper.html')

@app.route('/search', methods=['POST'])
def search():
    query = request.form['query']
    command = f'torify python3 scrapper/main.py -k {query}'

    try:
        subprocess.check_output(command, shell=True, text=True)
        
        # Read the content of onion_sites.csv
        with open('onion_sites.csv', 'r', newline='', encoding='utf-8') as file:
            csv_reader = csv.reader(file)
            onion_sites = [row[0] for row in csv_reader]

        response = jsonify({'result': onion_sites})
        response.headers.add('Access-Control-Allow-Origin', '*')  # Allow requests from any origin
        return response
    except subprocess.CalledProcessError as e:
        return jsonify({'error': f"Error executing the command: {e}"})

if __name__ == '__main__':
    app.run()
