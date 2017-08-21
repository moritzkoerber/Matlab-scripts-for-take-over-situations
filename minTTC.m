%% Zeit bis zur Übernahme

clear all 

%% Schleife bilden
for n = 1:40;
    
% clearvars('*','-except','n','Zeitspanne.(Personenbezeichnung)') 
    

if n<10
    Personenbezeichnung = ['Vp0',num2str(n)];
else
    Personenbezeichnung = ['Vp',num2str(n)];
end

%% Laden der relevanten Spalten (Messzeitpunkt, Streckenmeter, Bremspedalstellung, Gaspedalstellung, Lenkung)

% if n==3
ds = datastore(['C:\Users\Mo\Desktop\Eva\Michi TOT\Silabdaten\',Personenbezeichnung,'.1.asc'],'TreatAsMissing','NA','MissingValue',0);

ds.SelectedVariableNames = {'Var1','Var4','Var19','Var18','Var21','Var8','Var28','Var14','Var20'};

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
speed = cell2mat(table2cell(Vars(1:end,9))); 
% Abschnitte definieren

t3 = CourseID ==3;

Streckenmeter_t3 = Streckenmeter(t3);
CurrentLane_t3 = CurrentLane(t3);
HeadwayDistance_t3 = HeadwayDistance(t3);
speed_t3=speed(t3);

% vehiclePosition = (t3,8383,7);				#50m hinter dem Warndreieck
%(sign.warndreieck,8333,12),					#8333 5 min ab start course 3

%% Zeilennummer von TOR
%% (t4, 8333, Normal, 7, Automation, LaneChange, -1),		#35m (1.2s) vor dem Hindernis schert die Automation aus (Hindernis bei 8368m)
[bla index_TOR] = min(abs(Streckenmeter_t3-8333)); 
Zeilennummer_TOR = index_TOR(1);

%% Zeilennummer vor TOR

[bla index_vor_TOR] = min(abs(Streckenmeter_t3-8000)); 
Zeilennummer_vor_TOR = index_vor_TOR(1);

%% Schneiden der Variablen Lenkung, Bremse und Gaspedal

HeadwayDistance_ab_TOR = HeadwayDistance_t3(Zeilennummer_vor_TOR:Zeilennummer_TOR);
CurrentLane_ab_TOR = CurrentLane_t3(Zeilennummer_vor_TOR:Zeilennummer_TOR);
Streckenmeter_ab_TOR = Streckenmeter_t3(Zeilennummer_vor_TOR:Zeilennummer_TOR);
speed_ab_TOR =speed_t3(Zeilennummer_vor_TOR:Zeilennummer_TOR);

current_speed =100;
minTTC = 1000;
for i=1:length(HeadwayDistance_ab_TOR)
   if  CurrentLane_ab_TOR(i) == 7
        if 8333-Streckenmeter_ab_TOR(i) < minTTC
        minTTC=Streckenmeter_ab_TOR(i);
        current_speed = speed_ab_TOR(i);
        end
   end 
end

minTTC=(8333-minTTC)/(current_speed/3.6);
xlswrite('C:\Users\Mo\Desktop\Situation 2_minTTC.xlsx',n,'Tabelle1',['A',num2str(1+n)]);
xlswrite('C:\Users\Mo\Desktop\Situation 2_minTTC.xlsx',minTTC,'Tabelle1',['B',num2str(1+n)]);


end
disp('Analysis finished')
