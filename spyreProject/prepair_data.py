# -*- coding: utf-8 -*-
"""
Created on Wed Jun  8 20:57:35 2022

@author: Daria
"""

import pandas as pd
import re 

def prepair_data(file):
    head = list(pd.read_excel(file, nrows = 1, skiprows = 2, 
                              header = None).iloc[0])
    df = pd.read_excel(file, skiprows = 4, header = None, 
                       names = head)
    df = df[df['Код'].notna()]
    df['Код'] = pd.to_numeric(df['Код'], downcast = 'integer')
    df = df.set_index(['Код'])
    df[['Имя', 'Производитель']] = df['Наименование товаров'].str.split('пр'
                                                'оизв. ', expand = True)
    df['Имя'] = df['Имя'].str.replace('–' , '-')
    df[['Исполнитель', 'Название']] = df['Имя'].str.split( '-', 1, 
                                                          expand = True)
    df['Год'] = [re.search(r'; \d\d.{2};', str(r))[0][2:-1] if 
                 re.search(r'; \d\d.{2};', str(r)) != None else '-'
                   for r in df['Тех. данные'].values]
    df[['Тех. данные', 'Жанр']] = df['Тех. данные'].str.split(r'; \d\d.{2};', 
                                                              expand = True)
    df = df[df['Кол-во'] > 0].fillna('_')
    df['Кол-во'] = pd.to_numeric(df['Кол-во'], downcast = 'integer')
    df = df.replace(['Geramny', 'Poptugal', '2083', 'Electromic'],
                    ['Germany', 'Portugal', '2003', 'Electronic'], 
                    regex = True)
    df = df[df['Примечание'] != 'пакет для пластинок']
    df = df.drop(['Ваш заказ', 'Имя', 'Наименование товаров'], axis = 1)
    return df.set_index(['Код'])
