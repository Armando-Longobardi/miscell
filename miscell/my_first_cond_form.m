clc
clear

DataFileName='C:\Users\longoar001\Documents\MATLAB\CTRoutines\trunk\AL\miscell\Excel_with_cond_form.xlsm';
file='Result4.xlsm';
data=rand(5,5);
range='B2';
file = fullfile(pwd, file);
Excel = actxserver('Excel.Application');
Excel.Visible = true;
Workbooks = Excel.Workbooks;
Workbook=Workbooks.Open(DataFileName);

%write numbers
ran = Excel.Activesheet.get('Range',range);
ran.value = data;
ran.Select
% conditional formatting
Excel.Run('cond_form')

%
Workbook.SaveAs(file,52);
Workbook.Close;
Excel.Quit;
Excel.delete
