import argparse
import requests
import re
import csv

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

def main():
    parser = argparse.ArgumentParser(description='Onion Sites Scraper')
    parser.add_argument('-k', '--keyword', help='Search keyword', required=True)
    parser.add_argument('-o', '--output', help='Output CSV file', default='onion_sites.csv')
    args = parser.parse_args()

    result = search(args.keyword, args.output)
    print(result)

if __name__ == '__main__':
    main()
