%% Zeit bis zur Übernahme

clear all 

%% Schleife bilden
for n = 21:40;
    
% clearvars('*','-except','n','Zeitspanne.(Personenbezeichnung)') 
    

if n<10
    Personenbezeichnung = ['Vp0',num2str(n)];
else
    Personenbezeichnung = ['Vp',num2str(n)];
end

%% Laden der relevanten Spalten (Messzeitpunkt, Streckenmeter, Bremspedalstellung, Gaspedalstellung, Lenkung)

% if n==3
ds = datastore(['H:\Silabdaten\',Personenbezeichnung,'.1.asc'],'TreatAsMissing','NA','MissingValue',0);

ds.SelectedVariableNames = {'Var1','Var4','Var19','Var18','Var21','Var8'};

Vars = readall(ds);

% Definition der Variablen

Messzeitpunkt = cell2mat(table2cell(Vars(1:end,1)));
Streckenmeter = cell2mat(table2cell(Vars(1:end,2)));
Lenkradwinkel_rad = cell2mat(table2cell(Vars(1:end,3)));
Bremspedalstellung = cell2mat(table2cell(Vars(1:end,4)));
Gaspedalstellung = cell2mat(table2cell(Vars(1:end,5)));
CourseID = cell2mat(table2cell(Vars(1:end,6)));

Lenkradwinkel_deg = Lenkradwinkel_rad*(360/(2*pi));

% Abschnitte definieren

for i = 1:length(Streckenmeter)-1
   Diff_Meter_Zeitschritt(i) =  abs(Streckenmeter(i)-Streckenmeter(i+1) > 100); 
       
end

Abschnitte = find(Diff_Meter_Zeitschritt);

%% Course t3 aus Variablen herausschneiden

Streckenmeter = Streckenmeter(Abschnitte(1)+1:Abschnitte(2));
Lenkradwinkel_rad = Lenkradwinkel_rad(Abschnitte(1)+1:Abschnitte(2));
Bremspedalstellung = Bremspedalstellung(Abschnitte(1)+1:Abschnitte(2));
Gaspedalstellung = Gaspedalstellung(Abschnitte(1)+1:Abschnitte(2));
Lenkradwinkel_deg = Lenkradwinkel_deg(Abschnitte(1)+1:Abschnitte(2));

%% Zeilennummer von TOR

[bla index_TOR] = min(abs(Streckenmeter-8223)); 
Zeilennummer_TOR = index_TOR(1);

%% Zeilennummer vor TOR

[bla index_vor_TOR] = min(abs(Streckenmeter-7900)); 
Zeilennummer_vor_TOR = index_vor_TOR(1);

%% Schneiden der Variablen Lenkung, Bremse und Gaspedal

Lenkradwinkel_deg_ab_TOR = Lenkradwinkel_deg(Zeilennummer_vor_TOR:end);
Bremspedalstellung_ab_TOR = Bremspedalstellung(Zeilennummer_vor_TOR:end);
Gaspedalstellung_ab_TOR = Gaspedalstellung(Zeilennummer_vor_TOR:end);

%% Zeilennummer Eingriff

Grenzwert_Lenkung = 2;
Grenzwert_Bremse = 0.4;
Grenzwert_Gaspedal = 0.4;

A = abs(Lenkradwinkel_deg_ab_TOR) > Grenzwert_Lenkung;  
B = abs(Bremspedalstellung_ab_TOR) > Grenzwert_Bremse;
C = abs(Bremspedalstellung_ab_TOR) > Grenzwert_Gaspedal;
Eingriff_Lenkung = find(A,1);
Eingriff_Bremse = find(B,1);
Eingriff_Gaspedal = find(C,1);

Eingriff = min([Eingriff_Lenkung,Eingriff_Bremse,Eingriff_Gaspedal]);

%% Zeit bis zum Eingriff

Zeilennummer_TOR = abs(Zeilennummer_vor_TOR-Zeilennummer_TOR);

Zeitspanne_bis_Eingriff = ((Eingriff-Zeilennummer_TOR)/120);

Zeitspanne.(Personenbezeichnung) = Zeitspanne_bis_Eingriff;

xlswrite('C:\Users\Michael\Desktop\Skript_Moritz\Situation 2.xlsx',Zeitspanne_bis_Eingriff,'Tabelle1',['F',num2str(1+n)]);

end
disp('Analysis finished')
