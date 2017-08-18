%% Zeit bis zur Übernahme

clear all 

%% Schleife bilden
for n = 3:18;
    
% clearvars('*','-except','n','Zeitspanne.(Personenbezeichnung)') 
    

if n<10
    Personenbezeichnung = ['Vp0',num2str(n)];
else
    Personenbezeichnung = ['Vp',num2str(n)];
end

%% Laden der relevanten Spalten (Messzeitpunkt, Streckenmeter, Bremspedalstellung, Gaspedalstellung, Lenkung)

% if n==3
ds = datastore(['C:\Users\Mo\Desktop\Eva\Michi TOT\Silabdaten\',Personenbezeichnung,'.1.asc'],'TreatAsMissing','NA','MissingValue',0);

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

t1 = CourseID ==1;

Streckenmeter_t1 = Streckenmeter(t1);
Bremspedalstellung_t1 = Bremspedalstellung(t1);
Gaspedalstellung_t1 = Gaspedalstellung(t1);
Lenkradwinkel_deg_t1 = Lenkradwinkel_deg(t1);
Lenkradwinkel_rad_t1 = Lenkradwinkel_rad(t1);

%% Zeilennummer von TOR

[bla index_TOR] = min(abs(Streckenmeter_t1-8333)); 
Zeilennummer_TOR = index_TOR(1);

%% Zeilennummer vor TOR

[bla index_vor_TOR] = min(abs(Streckenmeter_t1-7952)); 
Zeilennummer_vor_TOR = index_vor_TOR(1);

%% Schneiden der Variablen Lenkung, Bremse und Gaspedal

Lenkradwinkel_deg_ab_TOR = Lenkradwinkel_deg_t1(Zeilennummer_vor_TOR:Zeilennummer_TOR);
Bremspedalstellung_ab_TOR = Bremspedalstellung_t1(Zeilennummer_vor_TOR:Zeilennummer_TOR);
Gaspedalstellung_ab_TOR = Gaspedalstellung_t1(Zeilennummer_vor_TOR:Zeilennummer_TOR);
Streckenmeter_ab_TOR = Streckenmeter_t1(Zeilennummer_vor_TOR:Zeilennummer_TOR);

%% Zeilennummer Eingriff

Grenzwert_Lenkung = 2;
Grenzwert_Bremse = 0.4;
Grenzwert_Gaspedal = 0.4;

% Bremspedalstellung_ab_TOR = Bremspedalstellung_ab_TOR > Grenzwert_Bremse;

A = abs(Lenkradwinkel_deg_ab_TOR) > Grenzwert_Lenkung;  
B = abs(Bremspedalstellung_ab_TOR) > Grenzwert_Bremse;
C = abs(Gaspedalstellung_ab_TOR) > Grenzwert_Gaspedal;

Eingriff_Lenkung = find(A,1);
Eingriff_Bremse = find(B,1);
Eingriff_Gaspedal = find(C,1);
Eingriff = min([Eingriff_Lenkung,Eingriff_Bremse,Eingriff_Gaspedal]);
Streckenmeter_Eingriff = Streckenmeter_ab_TOR(Eingriff);
Eingriffsart ='-';
if Eingriff == Eingriff_Lenkung
    disp('Lenkung');
    Eingriffsart = 'Lenkung';
elseif Eingriff == Eingriff_Bremse
    disp('Bremse');
    Eingriffsart = 'Bremse';
elseif Eingriff == Eingriff_Gaspedal
    disp('Gas');
    Eingriffsart = 'Gas';
else
    disp('-');
end

if sum(Eingriff) > 0
    Zeilennummer_TOR = abs(Zeilennummer_vor_TOR-Zeilennummer_TOR);
    Zeitspanne_bis_Eingriff = ((Eingriff-Zeilennummer_TOR)/120);
    Zeitspanne.(Personenbezeichnung) = Zeitspanne_bis_Eingriff;
    Eva_Zeitspanne_bis_Eingriff = ((8333-Streckenmeter_Eingriff)/(100/3.6));
    Eva_Zeitspanne.(Personenbezeichnung) = Eva_Zeitspanne_bis_Eingriff;
else 
    Zeitspanne_bis_Eingriff=0;
    Eva_Zeitspanne_bis_Eingriff=0;
end

xlswrite('C:\Users\Mo\Desktop\Situation 1.xlsx',n,'Tabelle1',['A',num2str(1+n)]);
xlswrite('C:\Users\Mo\Desktop\Situation 1.xlsx',Zeitspanne_bis_Eingriff,'Tabelle1',['B',num2str(1+n)]);
xlswrite('C:\Users\Mo\Desktop\Situation 1.xlsx',{Eingriffsart},'Tabelle1',['C',num2str(1+n)]);
xlswrite('C:\Users\Mo\Desktop\Situation 1.xlsx',Eva_Zeitspanne_bis_Eingriff,'Tabelle1',['D',num2str(1+n)]);

end
disp('Analysis finished')