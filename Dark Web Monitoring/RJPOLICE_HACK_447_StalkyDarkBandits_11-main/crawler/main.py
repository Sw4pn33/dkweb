import requests
import argparse
from bs4 import BeautifulSoup
import csv

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

if __name__ == "__main__":
    main()
