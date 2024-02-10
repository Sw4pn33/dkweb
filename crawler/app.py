# app.py

from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import time 
import subprocess
import csv

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

@app.route('/')
def index():
    return render_template('crawler.html')

# app.py

# ... (other imports)

@app.route('/search', methods=['POST'])
def search():
    query = request.form['query']
    keywordQuery = request.form['keywordQuery']
    command = f'torify python3 main.py -s {query} -k {keywordQuery}'

    print(f"Executing command: {command}")

    try:
        output = subprocess.check_output(command, shell=True, text=True)

        # Wait for a moment to ensure the CSV file is created
        time.sleep(2)

        # Read the content of keyword_onionsites.csv
        with open('keyword_onionsites.csv', 'r', newline='', encoding='utf-8') as file:
            csv_reader = csv.reader(file)
            onion_sites = [row[0] for row in csv_reader]

        response = jsonify({'result': onion_sites})
        response.headers.add('Access-Control-Allow-Origin', '*')  # Allow requests from any origin
        return response
    except subprocess.CalledProcessError as e:
        return jsonify({'error': f"Error executing the command: {e}"})
    except Exception as e:
        return jsonify({'error': f"An unexpected error occurred: {e}"})


    
@app.route('/keyword', methods=['POST'])
def keyword_search():
    keyword = request.form['keyword']
    command = f'torify python3 main.py -k {keyword} -u onion_sites.csv'

    try:
        subprocess.check_output(command, shell=True, text=True)
        
        # Read the content of keyword_onionsites.csv
        with open('keyword_onionsites.csv', 'r', newline='', encoding='utf-8') as file:
            csv_reader = csv.reader(file)
            onion_sites = [row[0] for row in csv_reader]

        response = jsonify({'result': onion_sites})
        response.headers.add('Access-Control-Allow-Origin', '*')  # Allow requests from any origin
        return response
    except subprocess.CalledProcessError as e:
        return jsonify({'error': f"Error executing the command: {e}"})


if __name__ == '__main__':
    app.run(port=5001)
