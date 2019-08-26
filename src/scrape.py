#!/usr/bin/python

import numpy as np
import pandas as pd
import os
import re
import logging
import requests
from bs4 import BeautifulSoup

DOMAIN = "https://www.footballoutsiders.com/stats"
PAGES = ["ol", "dl", "teamoff", "teamdef", "teamst", "rb", "qb", "wr", "te"]
DATA_PATH = "data/outsiders/"

# TODO: make script argument
YEAR = 2018


def format_text(s):
    s = s.replace("\n", " ").replace("\t", " ")
    while s[-1] == " ":
        s = s[:-1]
    i = 0
    while i < len(s):
        if i == 0 and s[i] == "":
            s = s[1:]
        elif i > 0 and s[i - 1] == " " and s[i] == " ":
            s = "{}{}".format(s[:i], s[i + 1 :])
        else:
            i += 1
    return s


def collect_columns(table):
    logging.info("collecting table header contents")
    columns = []
    header = table.findAll("thead")[-1].findAll("tr")[-1]
    for i, field in enumerate(header.children):
        try:
            column = format_text(field.text)
            columns.append(column)
        except:
            continue
    return columns


def collect_data(table):
    logging.info("collecting table data contents")
    body = table.findChild("tbody")
    if body is not None:
        rows = body.findChildren("tr")
    else:
        rows = table.findChildren("tr")
    data = []
    for i, row in enumerate(rows):
        cells = []
        if len(row.findChildren("th")) > len(row.findChildren("td")):
            continue
        for j, cell in enumerate(row.children):
            try:
                cells.append(format_text(cell.text))
            except:
                continue
        data.append(cells)
    return data


def extract_table(response):
    logging.info("extracting table from page response")
    table_index = 0
    # extract the table elements
    soup = BeautifulSoup(response.text, "html.parser")
    tables = soup.findAll("table")
    table = tables[table_index]
    # isolate the dataframe components
    columns = collect_columns(table)
    data = collect_data(table)
    # validate dimensions
    n_cols = len(columns)
    assert np.all(np.asarray([len(row) for row in data]) == n_cols), "inconsistent number of column cells observed"
    assert n_cols == len(columns), "header column count ({}) inconsistent with body column count ({})".format(
        len(columns), n_cols
    )
    # construct dataframe and return
    df = pd.DataFrame(np.asarray(data), columns=columns)
    return auto_convert(df)


def fetch_table_data(page="{}/stats/ol".format(DOMAIN), save_location=None):
    logging.info("fetching response from request to page {}".format(page))
    response = requests.get(page)
    df = extract_table(response)
    if save_location is None:
        save_location = "data/{}.csv".format(page.split("/")[-1])
    logging.info("saving resulting dataset to {}".format(save_location))
    if not os.path.exists(os.path.split(save_location)[0]):
        logging.debug("creating nonexistent output directory")
        os.makedirs(os.path.split(save_location)[0])
    df.to_csv(save_location, index=False)
    return df


# utility function for matching all strings in an array to the same regex
def all_match(pattern, values):
    return sum([bool(re.search(pattern, s)) for s in values]) == len(values)


def auto_convert(df):
    column_types = df.apply(lambda x: pd.api.types.infer_dtype(x, skipna=True), axis=0)
    for j, column in enumerate(df):
        if column_types[j] == "string":
            values = df.iloc[:, j].values
            # skip ratios
            if all_match(r"\d+/\d+", values):
                continue
            # percentage conversions
            if all_match(r"-?\d*[,\.]?\d+%", values):
                df.iloc[:, j] = [float(s.replace("%", "").replace(",", "")) / 100 for s in values]
            # float conversions
            elif all_match(r"-?\d*[,\.]?\d+", values):
                df.iloc[:, j] = [float(s.replace(",", "")) for s in values]
            # integer conversions
            elif all_match(r"-?\d+", values):
                df.iloc[:, j] = [int(s) for s in values]
        else:
            continue
    return df


def scrape_outsiders(domain=DOMAIN, pages=PAGES, year=YEAR, data_path=DATA_PATH):
    data = {}
    for page in pages:
        url = "{}/{}/{}".format(domain, page, year)
        logging.info("attempting to scrape tabular data from {}".format(url))
        try:
            data[page] = fetch_table_data(page=url, save_location="{}/{}/{}.csv".format(data_path, year, page))
        except Exception as error:
            logging.error("failed to fetch tabular data from {}:\n{}".format(url, error))
    return data


if __name__ == "__main__":
    scrape_outsiders()
