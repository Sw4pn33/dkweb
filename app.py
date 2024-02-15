#!/usr/bin/env python3

from flask import Flask, render_template, request, jsonify
import requests
import re
import csv
from bs4 import BeautifulSoup
import argparse

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

def extract_onion_sites(content):
    regex_query = r"\w+\.onion"
    onion_sites = re.findall(regex_query, content)
    onion_sites = list(set(onion_sites))
    onion_sites_with_http = ["http://" + site for site in onion_sites]
    return onion_sites_with_http
    
def write_to_csv(onion_sites, output_file):
    with open(output_file, 'w', newline='', encoding='utf-8') as file:
        csv_writer = csv.writer(file)
        for site in onion_sites:
            csv_writer.writerow([site])

def search(query, output_file):
    base_url = f"https://ahmia.fi/search/?q={query}"

    try:
        response = requests.get(base_url)
        response.raise_for_status()

        if response.status_code == 200:
            content = response.text
            onion_sites = extract_onion_sites(content)
            write_to_csv(onion_sites, output_file)
            return "CSV file updated with Onion Sites."
        else:
            return f"Error: {response.status_code} - {response.text}"

    except requests.exceptions.RequestException as e:
        return f"Error: {e}"

def crawl_url(url, keyword):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            text_content = soup.get_text()

            if keyword.lower() in text_content.lower():
                print(f"Keyword '{keyword}' found on {url}")
                
                # To Save the URL to keyword_onionsites.csv
                with open('keyword_onionsites.csv', 'a', newline='', encoding='utf-8') as file:
                    csv_writer = csv.writer(file)
                    csv_writer.writerow([url])
    except Exception as e:
        print(f"Error crawling {url}: {e}")

def main():
    parser = argparse.ArgumentParser(description="Web crawler with keyword search")
    parser.add_argument("-u", "--url_list", help="Path to a file containing a list of URLs")
    parser.add_argument("-s", "--single_onion", help="Onion site URL to crawl")
    parser.add_argument("-k", "--keyword", required=True, help="Keyword to search for")
    args = parser.parse_args()

    if args.url_list:
        with open(args.url_list, "r") as file:
            urls = file.read().splitlines()
        
        for url in urls:
            crawl_url(url, args.keyword)
    elif args.single_onion:
        crawl_url(args.single_onion, args.keyword)  # Update function call here
    else:
        print("Please provide either a list of URLs (-u) or a single onion site (-s).")

if __name__ == '__main__':
    app.run(host='143.110.188.66', port=5000, debug=True)
