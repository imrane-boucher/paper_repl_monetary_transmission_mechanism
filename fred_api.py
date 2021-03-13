# This python script, automates the collection process of macroeconomics time series from the FRED Database
# using the FRED API. Fill the Indicators of interest in the FILLING AREA, once the script is launched
# the time series will be automatically downloaded for each countries of need under xlsx format.

from time import sleep

import pandas as pd
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# ---------------- FILLING AREA --------------------------
# Search Indicators for the data to collect:
# you can change those parameters depending on which data you want to collect
countries = ['France', 'Germany', 'UK', 'Italy', 'US']
economic_areas = ['Euro Area', 'United States']
com_variables = ['industrial production index', 'consumer price index', 'import price index','interbank immediate rates']
spe_variables = {'Euro Area': ['M3', 'effective exchange rate'], 'United States': ['M1']}
horizon = 'monthly'
measur_unit = 'currency'
start_date = '2004-01-01' # YYYY-MM-DD
end_date = '2020-01-01'
# ----------------------------------------------------------

for country in countries:
    for var in com_variables:
        # create the string to search the correct series in the server
        var_intol = var.split()
        var_search = '+'.join(var_intol)
        search_str = country.lower()+'+'+var_search+'+'+horizon

        # code enabling to solve the connection to server error
        # https://stackoverflow.com/questions/23013220/max-retries-exceeded-with-url-in-requests
        session = requests.Session()
        retry = Retry(connect=3, backoff_factor=0.5)
        adapter = HTTPAdapter(max_retries=retry)
        session.mount('http://', adapter)
        session.mount('https://', adapter)

        api_key = 'your_api_key'


        # first call to the the server to retrieve the id of the data series we want to collect
        response = requests.get('https://api.stlouisfed.org/fred/series/search?search_text=**{}**&api_key={}&file_type=json'.format(search_str,api_key))
        sleep(10)
        data = response.json()

        titles = []
        series_id = []
        selected_titles = []
        # create a dict to link each series (title) to its series id
        for serie in data['seriess']:
            titles.append(serie['title'])
            series_id.append(serie['id'])

        series_dict = dict(zip(titles, series_id))
        

        # loop over the different series in list to retrieve the exact one we are interested in
        for title in titles:
            if any(word.lower() in title.lower() for word in var_intol):
                print(title)
                selected_titles.append(title)

        print(selected_titles)
        try:
            my_serie_id = series_dict[selected_titles[0]]
            # collect the id of the specific serie we want to get
            print(my_serie_id)

            response2 = requests.get('https://api.stlouisfed.org/fred/series/observations?series_id={}&api_key={}&file_type=json&observation_start={}&observation_end={}&frequency=m'.format(my_serie_id, api_key, start_date, end_date))
            sleep(10)
            data2 = response2.json()

            dates = [d['date'] for d in  data2['observations']]
            values = [d['value'] for d in data2['observations']]
            df = pd.DataFrame(values, index=dates, columns=[selected_titles[0]])
            # make sure the data saved in excel files are numeric types
            df[selected_titles[0]] = df[selected_titles[0]].astype(str).astype(float)
            print(df.head())
            df.to_excel('datasets/{}_{}.xlsx'.format(country, var))
        except IndexError:
            # if data for specific country and var not found notify user + continue the loop
            print("Data couldn't be retrieve for the following country and variable:" + country + "/" + var)
            pass


# to collect variables speciffically for a country
for area in economic_areas:
    for var in spe_variables[area]:
        # create the string to search the correct series in the server
        area_intol = area.split()
        area_search = '+'.join(area_intol)
        var_intol = var.split()
        var_search = '+'.join(var_intol)
        search_str = area_search.lower()+'+'+var_search+'+'+measur_unit+'+'+horizon
        print(search_str)
        # code enabling to solve the connection to server error
        # https://stackoverflow.com/questions/23013220/max-retries-exceeded-with-url-in-requests
        session = requests.Session()
        retry = Retry(connect=3, backoff_factor=0.5)
        adapter = HTTPAdapter(max_retries=retry)
        session.mount('http://', adapter)
        session.mount('https://', adapter)

        api_key = '5bc9c8b1cdd3dba3ffd333590bf73234'


        # first call to the the server to retrieve the id of the data series we want to collect
        response = requests.get('https://api.stlouisfed.org/fred/series/search?search_text=**{}**&api_key={}&file_type=json'.format(search_str,api_key))
        sleep(10)
        data = response.json()

        titles = []
        series_id = []
        selected_titles = []
        # create a dict to link each series (title) to its series id
        for serie in data['seriess']:
            titles.append(serie['title'])
            series_id.append(serie['id'])

        series_dict = dict(zip(titles, series_id))
        # loop over the different series in list to retrieve the exact one we are interested in
        for title in titles:
            if any(word.lower() in title.lower() for word in var_intol):
                print(title)
                selected_titles.append(title)

        print(selected_titles)
        try:
            my_serie_id = series_dict[selected_titles[0]]
            # collect the id of the specific serie we want to get
            print(my_serie_id)

            response2 = requests.get('https://api.stlouisfed.org/fred/series/observations?series_id={}&api_key={}&file_type=json&observation_start={}&observation_end={}&frequency=m'.format(my_serie_id, api_key, start_date, end_date))
            sleep(10)
            data2 = response2.json()

            dates = [d['date'] for d in  data2['observations']]
            values = [d['value'] for d in data2['observations']]
            df = pd.DataFrame(values, index=dates, columns=[selected_titles[0]])
            # make sure the data saved in excel files are numeric types
            df[selected_titles[0]] = df[selected_titles[0]].astype(str).astype(float)
            print(df.head())
            df.to_excel('datasets/{}_{}.xlsx'.format(area, var))
        except IndexError:
            # if data for specific country and var not found notify user + continue the loop
            print("Data couldn't be retrieve for the following country and variable:" + area + "/" + var)
            pass