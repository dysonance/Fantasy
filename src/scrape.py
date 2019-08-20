#!/usr/bin/python

import pandas as pd
import numpy as np
import os
import logging
import requests
from bs4 import BeautifulSoup

DOMAIN = "https://www.footballoutsiders.com/stats"
PAGES = ["ol", "dl", "teamoff", "teamdef", "teamst", "rb", "qb", "wr", "te"]
DATA_PATH = "data/outsiders/"


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
    rows = body.findChildren("tr")
    data = []
    for i, row in enumerate(rows):
        cells = []
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
    dataframe = pd.DataFrame(np.asarray(data), columns=columns)
    return dataframe


def fetch_table_data(page="{}/stats/ol".format(DOMAIN), save_location=None):
    logging.info("fetching response from request to page {}".format(page))
    response = requests.get(page)
    dataframe = extract_table(response)
    if save_location is None:
        save_location = "data/{}.csv".format(page.split("/")[-1])
    logging.info("saving resulting dataset to {}".format(save_location))
    if not os.path.exists(os.path.split(save_location)[0]):
        logging.debug("creating nonexistent output directory")
        os.makedirs(os.path.split(save_location)[0])
    dataframe.to_csv(save_location, index=False)
    return dataframe


def scrape_outsiders(domain=DOMAIN, pages=PAGES, data_path=DATA_PATH):
    data = {}
    for page in pages:
        url = "{}/{}".format(domain, page)
        logging.info("attempting to scrape tabular data from {}".format(url))
        try:
            data[page] = fetch_table_data(page=url, save_location="{}/{}.csv".format(data_path, page))
        except Exception as error:
            logging.error("failed to fetch tabular data from {}:\n{}".format(url, error))
    return data
