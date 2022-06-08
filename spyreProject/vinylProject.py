# -*- coding: utf-8 -*-
"""
Created on Wed Jun  8 12:12:34 2022

@author: Daria
"""

from prepair_data import prepair_data
import matplotlib.pyplot as plt
from spyre import server
import numpy as np
import re 

df = prepair_data('Винил 03.06.22.xls')

years = list(np.unique(df['Год']))

for rep in ('19??', '20??', '-'):
    if rep in years:
        years.remove(rep)

ganres = []
for i in np.unique(df['Жанр']):
    for j in str(i).split(','):
        ganres.append(re.split("[\(,\)\d;'/]", j)[0].strip())
ganres = sorted(np.unique(ganres))[2:-2]
ganres.insert(0, 'Всі')

singers = list(np.unique(df['Исполнитель']))
singers.insert(0, 'Всі')

producer = list(np.unique(df['Производитель']))
producer.insert(0, 'Всі')

class SimpleApp(server.App):
    
    title = "База даних магазину вінілових платівок"
    
    inputs = [{
        "type": "slider",
        'label' : 'Ціна, грн',
        "key": "Цена",
        "value": 1000, 
        "max": 3000,
        "action_id": "update_data"
    },
    {
        "type": "slider",
        'label' : 'Рік видання',
        "key": "Год",
        "value": '1992', 
        'min' : years[0],
        "max": years[-1],
        "action_id": "update_data"
    },
    {
        "type": 'dropdown',
        "label": 'Жанр',
        "options": [dict({'label' : l, 'value' : l}) for l in ganres],
        "value": 'Всі',
        "key": 'Жанр',
        "action_id": "update_data"
    },
    {
        "type": 'dropdown',
        "label": 'Виконавець',
        "options": [dict({'label' : l, 'value' : l}) for l in singers],
        "value": 'Всі',
        "key": 'Исполнитель',
        "action_id": "update_data"
    },
    {
        "type": 'checkboxgroup',
        "label": 'Країна виробника',
        "options": [dict({'label' : l, 'value' : l}) for l in producer],
        "value": 'Всі',
        "key": 'Производитель',
        "action_id": "update_data"
    },
    {
        "type": 'searchbox',
        "label": 'Назва',
        "value": '',
        "key": 'Название',
        "action_id": "update_data"
    }]


    controls = [{    
        "type" : "button",
        'label' : 'Пошук',
        "id" : "update_data"
    }]

    tabs = ["База", 'Трохи_статистики']

    outputs = [{
        "type": "table",
        "id": "mainTable",
        "control_id": "update_data",
        "tab": "База",
        "on_page_load": True
    },
    {
       "type": "plot",
       "id": "PricePlot",
       "control_id": "update_data",
       "tab": "Трохи_статистики"
    }]
    
    
    def select_data(self, params):
        ganre = params['Жанр']
        singer = params['Исполнитель']
        country = params['Производитель']
        name = params['Название']
        price = params['Цена']
        year = params['Год']
        df_ = df[(df['Цена'] <= price) & (df['Год'] <= str(year))]
        if ganre !='Всі':
            df_ = df_[df_['Жанр'].str.contains(ganre)]
        if singer !='Всі':
            df_  = df_[df_['Исполнитель'].str.contains(singer)]
        if country[0] != 'Всі':
            df_ = df_[sum(df_['Производитель'].str.contains(c) 
                          for c in country).astype(np.bool)]
        if name != '':
            df_ = df_[df_['Название'].str.lower().str.contains(name.lower())]
        return df_
    
    
    def mainTable(self, params):
        return self.select_data(params)
    
    
    def PricePlot(self, params):
        
        df_ = self.select_data(params)
        
        m = int(np.median(df_['Цена'].values))
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize = (21, 14))
        df_['Цена'].plot(ax = ax1, kind = 'hist', bins = m, color = 'teal', 
                              label = f'Медіанна ціна: {m} грн')
        ax1.set_title('Розподіл цін', fontsize = 15)
        ax1.legend(fontsize = 16)
        ax1.set_ylabel('Кількість в наявності', fontsize = 13)
        ax1.set_xlabel('Ціна, грн', fontsize = 13)
        ax1.set_facecolor('whitesmoke')
        
        bar = ax2.barh(producer[1:], [sum(df_[df_['Производитель'] == 
                    pr]['Кол-во']) for pr in producer[1:]], color = 'teal')
        ax2.bar_label(bar)
        ax2.set_title('Розподіл країн виробників', fontsize = 15)
        ax2.set_facecolor('whitesmoke')
        
        years_ = [y for y in years if y < str(params['Год'])]
        bar = ax3.bar(years_, [sum(df_[df_['Год'] == y]['Кол-во']) 
                               for y in years_], color = 'teal')
        ax3.bar_label(bar)
        ax3.set_xticklabels(years_, rotation = 70)
        ax3.set_ylabel('Кількість в наявності', fontsize = 13)
        ax3.set_title('Розподіл рокив виробництва', fontsize = 15)
        ax3.set_facecolor('whitesmoke')
        
        counts = [sum(df_[df_['Жанр'].str.contains(pr)]['Кол-во']) 
                  for pr in ganres]
        counts, ganres_ = list(zip(*sorted(zip(counts, ganres))))
        bar = ax4.barh(ganres_[-10:], [sum(df_[df_['Жанр'].str.contains(pr)]
                        ['Кол-во']) for pr in ganres_[-10:]], color = 'teal')
        ax4.bar_label(bar)
        ax4.set_title('ТОП-10 найпопулярніших жанрів', fontsize = 15)
        ax4.set_xlabel('Кількість в наявності', fontsize = 13)
        ax4.set_facecolor('whitesmoke')
        
        fig.tight_layout()
        
        return fig
    
if __name__ == '__main__':
       
       app = SimpleApp()
       app.launch()
