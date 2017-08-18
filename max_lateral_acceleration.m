%% Zeit bis zur Übernahme

clear all 

%% Schleife bilden
for n = 21:39;
    
% clearvars('*','-except','n','Zeitspanne.(Personenbezeichnung)') 
    

if n<10
    Personenbezeichnung = ['Vp0',num2str(n)];
else
    Personenbezeichnung = ['Vp',num2str(n)];
end

%% Laden der relevanten Spalten (Messzeitpunkt, Streckenmeter, Bremspedalstellung, Gaspedalstellung, Lenkung)

% if n==3
ds = datastore(['C:\Users\Mo\Desktop\Eva\Michi TOT\Silabdaten\',Personenbezeichnung,'.1.asc'],'TreatAsMissing','NA','MissingValue',0);

ds.SelectedVariableNames = {'Var1','Var4','Var19','Var18','Var21','Var8','Var28','Var14','Var22','Var49'};

Vars = readall(ds);

% Definition der Variablen

Messzeitpunkt = cell2mat(table2cell(Vars(1:end,1)));
Streckenmeter = cell2mat(table2cell(Vars(1:end,2)));
Lenkradwinkel_rad = cell2mat(table2cell(Vars(1:end,3)));
Bremspedalstellung = cell2mat(table2cell(Vars(1:end,4)));
Gaspedalstellung = cell2mat(table2cell(Vars(1:end,5)));
CourseID = cell2mat(table2cell(Vars(1:end,6)));
HeadwayDistance = cell2mat(table2cell(Vars(1:end,7)));
CurrentLane = cell2mat(table2cell(Vars(1:end,8))); 
maxlat = cell2mat(table2cell(Vars(1:end,10))); 
% Abschnitte definieren

t3 = CourseID ==3;

Streckenmeter_t3 = Streckenmeter(t3);
maxlat_t3 = maxlat(t3);


% vehiclePosition = (t3,8383,7);                #50m hinter dem Warndreieck
%(sign.warndreieck,8333,12),                    #8333 5 min ab start course 3

%% Zeilennummer von TOR
%% (t4, 8333, Normal, 7, Automation, LaneChange, -1),       #35m (1.2s) vor dem Hindernis schert die Automation aus (Hindernis bei 8368m)
[bla index_obstacle] = min(abs(Streckenmeter_t3-8333)); 
Zeilennummer_obstacle = index_obstacle(1);

%% Zeilennummer vor TOR

[bla index_TOR] = min(abs(Streckenmeter_t3-8000)); 
Zeilennummer_TOR = index_TOR(1);

%% Schneiden der Variablen Lenkung, Bremse und Gaspedal

maxlat_situation = maxlat_t3(Zeilennummer_TOR:Zeilennummer_obstacle);

maxlat_min = min(maxlat_situation);
maxlat_max = max(maxlat_situation);

xlswrite('C:\Users\Mo\Desktop\Situation 2_maxlat.xlsx',n,'Tabelle1',['A',num2str(1+n)]);
xlswrite('C:\Users\Mo\Desktop\Situation 2_maxlat.xlsx',maxlat_min,'Tabelle1',['B',num2str(1+n)]);
xlswrite('C:\Users\Mo\Desktop\Situation 2_maxlat.xlsx',maxlat_max,'Tabelle1',['C',num2str(1+n)]);

end
disp('Analysis finished')
