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

ds.SelectedVariableNames = {'Var1','Var4','Var19','Var18','Var21','Var8','Var28','Var14'};

Vars = readall(ds);

% Definition der Variablen

Messzeitpunkt = cell2mat(table2cell(Vars(1:end,1)));
Streckenmeter = cell2mat(table2cell(Vars(1:end,2)));
Lenkradwinkel_rad = cell2mat(table2cell(Vars(1:end,3)));
Bremspedalstellung = cell2mat(table2cell(Vars(1:end,4)));
Gaspedalstellung = cell2mat(table2cell(Vars(1:end,5)));
CourseID = cell2mat(table2cell(Vars(1:end,6)));

Lenkradwinkel_deg = Lenkradwinkel_rad*(360/(2*pi));

t3 = CourseID ==3;



%% Course t3 aus Variablen herausschneiden

Streckenmeter_t3 = Streckenmeter(t3);
Lenkradwinkel_rad_t3 = Lenkradwinkel_rad(t3);
Bremspedalstellung_t3 = Bremspedalstellung(t3);
Gaspedalstellung_t3 = Gaspedalstellung(t3);
Lenkradwinkel_deg_t3 = Lenkradwinkel_deg(t3);

%% Zeilennummer von TOR

[bla index_TOR] = min(abs(Streckenmeter_t3-8223)); 
Zeilennummer_TOR = index_TOR(1);

%% Zeilennummer vor TOR

[bla index_vor_TOR] = min(abs(Streckenmeter_t3-7900)); 
Zeilennummer_vor_TOR = index_vor_TOR(1);

%% Schneiden der Variablen Lenkung, Bremse und Gaspedal

Lenkradwinkel_deg_ab_TOR = Lenkradwinkel_deg_t3(Zeilennummer_vor_TOR:end);
Bremspedalstellung_ab_TOR = Bremspedalstellung_t3(Zeilennummer_vor_TOR:end);
Gaspedalstellung_ab_TOR = Gaspedalstellung_t3(Zeilennummer_vor_TOR:end);

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

xlswrite('C:\Users\Mo\Desktop\Situation 2_tot.xlsx',Zeitspanne_bis_Eingriff,'Tabelle1',['F',num2str(1+n)]);

end
disp('Analysis finished')
