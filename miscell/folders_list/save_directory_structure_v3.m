%% Inizializzo: 
%cancello tutto 
clear 
clc
close all

%scelgo cartella di lavoro
start=uigetdir(cd,'Choose folder to analyze');
cd(start);

excel_dir=uigetdir(start,'Choose where the Excel will be created');
%definisco automaticamente il nome dell'excel
excel_name=correct_name(dir_name(start));
%% Cose Random
%% Corpo principale
%Richiamo la funzione che, per ricorsione, spero faccia tutto il lavoro

file_searcher_v4( start,excel_name,excel_dir);

