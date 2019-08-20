import pandas as pd
import requests
from bs4 import BeautifulSoup

DOMAIN = "https://www.footballoutsiders.com"

def format_text(s):
    s = s.replace('\n', ' ').replace('\t', ' ')
    while s[-1] == ' ':
        s = s[:-1]
    i = 0
    while i < len(s):
        if i == 0 and s[i] == '':
            s = s[1:]
        elif i > 0 and s[i-1] == ' ' and s[i] == ' ':
            s = '{}{}'.format(s[:i], s[i+1:])
        else:
            i += 1
    return s


def collect_columns(table):
    columns = []
    header = table.findAll('thead')[-1].findAll('tr')[-1]
    for i, field in enumerate(header.children):
        try:
            column = format_text(field.text)
            print(column)
            columns.append(column)
        except:
            continue
    return columns


def fetch_oline_table(save_location="data/oline.csv"):
    pass
    page = '{}/stats/ol'.format(DOMAIN)
    response = requests.get(page)
    table_index = 0
    soup = BeautifulSoup(response.text, "html.parser")
    tables = soup.findAll('table')
    table = tables[table_index]
    columns = collect_columns(table)
    result = pd.DataFrame(columns=columns)
    # TODO: fill dataframe with table data
    return result
