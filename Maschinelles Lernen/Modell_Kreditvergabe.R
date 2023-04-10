# Bitte vorher prüfen!
# Installation von Packages (falls notwendig)
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("magrittr")
# install.packages("stats")
# install.packages("caret")
# install.packages("caTools")

# Vorbereitung - Laden der Daten
file_path = "C:\\Users\\Alwin\\OneDrive\\Dokumente\\AKAD\\00200_Module\\01_In Arbeit\\WEB78_Programmiersprachen R und Python\\Assignment\\loan.csv"
df <- read.csv(file_path, header = TRUE, sep = ",", stringsAsFactors = FALSE)

# Anzahl Zeilen und Spalten ausgeben:
paste0("Die Anzahl der Zeilen beträgt ", nrow(df))
paste0("Die Anzahl der Spalten beträgt ", ncol(df))



############################### Teilaufgabe 1a): Datenbereinigung ####################################
print("Nullwerte entfernen aus dem Datensatz")
# a.1) Zunächst gebe ich die Informationen zu den einzelnen Spalten aus um Auffälligkeiten zu eruieren.
summary(df)


# a.2) Dabei sind mir viele Spalten aufgefallen, die lediglich mit Nullwerten befüllt sind, diese werden zunächst entfernt.
df <- df[ , colSums(is.na(df))==0]
paste0("Die Anzahl der Spalten beträgt nun noch ", ncol(df))


# a.3) Die weitere Analyse sind noch die Spalten "policy_code", "acc_now_delinq" und "delinq_amnt" aufgefallen,
#      diese hatten sowohl bei Min. Median und Max. identische Werte. 
#      Ein kurzer Check zeigt das hier lediglich ein Wert eingetragen wurde:
unique(df$policy_code)
unique(df$acc_now_delinq)
unique(df$delinq_amnt)
# Auch die Spalte "pymnt_plan" enthält nur den Wert "n" und kann entfernt werden
unique(df$pymnt_plan)
# Auch die Spalte "initial_list_status" enthält nur den Wert "f" und kann entfernt werden
unique(df$initial_list_status)
# Auch die Spalte "application_type" enthält nur Werte "INDIVIDUAL" und kann entfernt werden
#      Löschen der überflüssigen Spalten:
df <- subset(df, select = -c(policy_code, acc_now_delinq, delinq_amnt, pymnt_plan, initial_list_status, application_type))
paste0("Die Anzahl der Spalten beträgt ", ncol(df))


# a.4) Zeilen löschen, die Nullwerte enthalten:
df <- na.omit(df)
paste0("Die Anzahl der Zeilen beträgt nun noch ", nrow(df))


# a.5) Desweiteren sind noch einige Spalten aufgefallen, bei denen sich Median und Mean sehr stark unterscheiden. 
#      Auch weil das 1. und 3. Quantil jeweils eine 0 enthalten ist das ein starkes Anzeichen für Spalten mit stark 
#      unbalancierten Daten. Diese Spalten werden also ebenfalls entfernt, da im Rahmen einer Modellbildung ungeeignet.
#      delinq_2yrs, pub_rec, out_prncp, out_prncp_inv, total_rec_late_fee, recoveries, collection_recovery_fee
# Genutzte Visualsierungen für die Analyse am Beispiel der Spalte "delinq_2yrs":
# barplot(with(df, table(delinq_2yrs)), beside = TRUE, legend = TRUE)
df <- subset(df, select = -c(delinq_2yrs, pub_rec, out_prncp, out_prncp_inv, total_rec_late_fee, recoveries, collection_recovery_fee))
#
#      Eine weitere Spalte "annual_inc" hat eine sehr starke Abweichung von 3. Perzentile zum Max. dies sollte näher angeschaut werden:
ggplot(df, aes(annual_inc)) + 
  geom_freqpoly()
# Hieraus lässt sich erkennen, dass das Set nicht ausbalanciert ist und es starke Ausreißer gibt. 
# Schaut man sich die ersten 1% der größten Einkommen an, so erkennt man, dass diese bereits stark abfallen:
head(df[order(-df$annual_inc), ]$annual_inc, nrow(df)/100)
# Für ein besser ausbalanciertes Datenset entferne ich die ersten 1% Einträge. Die Schwelle liegt bei 235.000
df <- df[df$annual_inc < 235000, ]
ggplot(df, aes(annual_inc)) + 
  geom_freqpoly()

ggplot(df, aes(last_pymnt_amnt)) + 
  geom_freqpoly()
# Nun ist der Graph besser ausbalanciert.

paste0("Die Anzahl der Zeilen beträgt nun noch ", nrow(df))
paste0("Die Anzahl der Spalten beträgt nun noch ", ncol(df))
##########################################################################################################


############################### Teilaufgabe 1b): Explorative Datenanalyse: ###############################
library(ggplot2)
# b.1) Erstellen Sie ein Frequenzdiagramme für die Variable „loan_amnt“ wenn der Zweck (Spalte „purpose“) 
#      den Wert „car“, „house“, „credit_card“ oder „small_business“ hat
filtered_df <- df[df$purpose %in% c("car", "house", "credit_card", "small_business"), ]
paste0("Die Anzahl der Zeilen gefiltert nach 'car', 'house', 'credit_card' oder 'small_business': ", nrow(filtered_df))
options(scipen=999)
ggplot(filtered_df, aes(x = purpose, y = loan_amnt, fill=purpose)) + 
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette="Blues") +
  labs(x = "Zweck", y = "Kreditsumme", title = "Kreditsummen nach Zweck") 
# Insight: Die meisten Kredite sind Kreditkartenbeträge 


# b.2) Erstellen Sie ein Frequenzdiagram für den Zinssatz „int_rate“. Transformieren Sie den Datensatz vorher 
#      von einem String in einen nummerischen Wert.
df$int_rate <- as.numeric(gsub("%", "", df$int_rate))
summary(df$int_rate)
ggplot(df, aes(x = int_rate)) +
  geom_freqpoly(bins = 50) +
  labs(x = "Zinsatz in %", y = "Anazhl Kredite", title = "Verteilung der Zinssätze")


# b.3) Führen Sie eine deskriptive statistische Analyse durch für die Spalten „loan_amnt“, 
#      „installment“, „int_rate“, „funded_amnt“, „annual_inc“, „grade“ und „sub_grade“. 
#      Transformieren Sie mögliche kategorische Werte in nummerische. Die statistische 
#      Analyse sollte mindestens eine Visualisierung pro Variable beinhalten (z.B. Boxplot), 
#      eine Analyse der wichtigsten Statistischen Werte je Variable und den Zusammenhang 
#      zwischen je zwei Variablen (z.B.: Korrelation)
### Annahme:
#   In dieser Aufgabe soll ich lediglich die hier aufgezählten Variablen sich entsprechend gegenüberstellen und keine weiteren
###

### Erste fünf Zeilen für die zu analysierenden Daten ausgeben:
head(df[, c("loan_amnt", "installment", "int_rate", "funded_amnt", "annual_inc", "grade", "sub_grade")],5)
### Umwandeln von grade und sub_grade in kategorische Werte: 
df$grade <- as.factor(df$grade)
df$sub_grade<- as.factor(df$sub_grade)

####################### loan_amnt #######################
summary(df$loan_amnt)
# Die Spanne der Kredite beträgt 500 - 35.000, die meisten Kredite (50%) liegen zwischen 5400 und 15000. Der 3. Perzentile
# nach zu Urteilen liegen die meisten Kredite bis 15.000, danach gibt es wenige Außreiser, das Histogram bestätigt
# die erste Analyse:
ggplot(df, aes(loan_amnt)) + 
  geom_histogram(aes(y=..density..), bins = 30, color="lightblue", fill="blue") +
  geom_density(alpha=0.2, fill="#FF6666") +
  labs(x = "Kredithöhe", y = "Verteilung", title = "Verteilung der Kredithöhen")
### Analyse der wichtigsten statistischen Werte:
# - Der Median liegt hier beim Balken mit der höhsten Verteilungsdichte um 10.000
# - Der Durchschnitt (11.134) liegt dabei etwas weiter rechts, das liegt daran, dass es einige Ausreißer Richtung 35.000 gibt,
#   diese beinflussen den Durchschnitt im wesentlichen in der Grafik in der horizontalen nach rechts
# - Die 1. und 3. Perzentile gibt an, dass 50% der Kredite zwischen 5.400 und 15.000 liegen. Wobei vor der 1. Perzentile die
#   Spanne der Kreditsumme mit 500 - 5.400 deutlich geringer ausfällt als die der 3. Perzentile mit einer Spanne 
#   von 15.000 - 35.000, das sind das 4-fache, was auch sehr deutlich aus der Grafik ersichtlich ist.
###
# Zusammenhang zwischen Zinssatz und Kredithöhe, ein Trend ist zu erkennen, je höher der Kredit, desto höher ist auch der Zins
ggplot(df, aes(x = loan_amnt, y = int_rate, color = int_rate)) +
  geom_point(size = 1) +
  geom_quantile(quantiles = 0.5) +
  labs(x = "Kredithöhe", y = "Zinssatz in %", title = "Korrelation Zinssatz zu Kredithöhe")

####################### installment #######################
summary(df$installment)
# Ähnliche wie auch bei der Kredithöhe erkennt man anhand der 3. Perzentile, dass die wenigsten Kredite eine
# monatliche Rate ab 426 haben. Zum Max. von 1305 ist das eine Differenz von knapp 900. Grafisch veranschaulicht: 
ggplot(df, aes(installment)) + 
  geom_histogram(aes(y=..density..), bins = 30, color="lightblue", fill="blue") +
  geom_density(alpha=0.2, fill="#FF6666") +
  labs(x = "Monatliche Rate", y = "Verteilung", title = "Verteilung der Monatlichen Raten")
### Analyse der wichtigsten statistischen Werte:
# - Der Median liegt bei einer monatlichen Rate von 278
# - Der Durchschnitt (322) liegt dabei weiter rechts, das liegt daran, dass es einige Ausreißer in diese Richtung gibt.
#   Es lässt sich vermuten, dass hier die Raten an der Krediithöhe bemessen wurden und mit dieser auch stark korrelieren.
# - Die 1. und 3. Perzentile gibt an, dass 50% der Raten zwischen 166 und 426 liegen. Wobei vor der 1. Perzentile die
#   Spanne wie auch bei der Kreditsumme deutlich geringer ist als bei der 3. Perzentile zum Maximum.
###
# Dies lässt ggf. eine Korrelation zwischen Kreditsumme und monatlicher Rate vermuten:
ggplot(df, aes(x = installment, y = loan_amnt, color = installment)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(x = "Monatliche Rate", y = "Kredithöhe", title = "Darstellung Monatliche Rate vs. Kredithöhe")
# Hier lässt sich eindeutig eine Korrelation erkennen. Wobei es auch aufällt, dass die Spanne der monatlichen Raten
# bei höheren Krediten auch höher ausfällt, das könnte mit der Kreditbewertung zusammen hängen und wird später weiter untersucht.

####################### int_rate #######################
summary(df$int_rate)
# Verteilung der Zinsen 
ggplot(df, aes(int_rate)) + 
  geom_histogram(aes(y=..density..), bins = 30, color="lightblue", fill="blue") +
  geom_density(alpha=0.2, fill="#FF6666") +
  labs(x = "Zinssatz in %", y = "Verteilung", title = "Verteilung der Zinsen")
### Analyse der wichtigsten statistischen Werte:
# - Der Median liegt bei einem Zinssatz von 11.8 % und ist nicht weit vom tatsächlichen Durchschnitt von 12%
#   Der Zinssatz erfährt also keine größere Streuung, wenn Kreditsumme oder montl. Rate Ausreißer enthalten.
# - Die 1. und 3. Perzentile gibt an, dass 50% der Zinssätze zwischen 9.25 % und 14.54 % liegen. Hier ist die Verteilung recht
#   linear und kaum auffällig. 
###
# Zinssätze richten sich zumeist an der Bewertung eines Kredits, hier ist es spannend herauszufinden ob es da eine
# Korrelation gibt;
ggplot(df, aes(x = grade, y = int_rate, color = grade)) +
  geom_boxplot() +
  scale_fill_brewer(palette="Blues") +
  labs(x = "Kreditbewertung (Klasse)", y = "Zinssatz", title = "Kreditberwetung vs. Zinssatz")
# Die Korrelation ist deutlich erkennbar, je besser bewertet (A ist die beste Bewertungsklasse) desto geringer der Zinssatz

####################### funded_amnt #######################
summary(df$funded_amnt)
# Verteilung der gewährten Kreditsummen, diese unterscheiden sich in der Verteilung von der loan_amnt nicht im Wesentlichen.
ggplot(df, aes(funded_amnt)) + 
  geom_histogram(aes(y=..density..), bins = 30, color="lightblue", fill="blue") +
  geom_density(alpha=0.2, fill="#FF6666") +
  labs(x = "Kredithöhe", y = "Verteilung", title = "Verteilung der Kredithöhen")
### Analyse der wichtigsten statistischen Werte:
# - Die Werte der tatsächlich gewährten Kreditsummen ähnen in den wichtigsten statistischen Werten den der angefragten Kreditsumme.
# - Die gewährte Kreditsumme weist von Natur aus eine starke Korrelation zum angeforderten Kreditbetrag auf.
###
# Hier könnte man sich eine Differenzspalte zwischen loan_amnt und funded_amnt bilden und diese ggü. funded_amnt darstellen lassen
df$diff_loan_amnt <- df$loan_amnt - df$funded_amnt
summary(df$diff_loan_amnt)
ggplot(df, aes(x = loan_amnt, y = diff_loan_amnt, color = diff_loan_amnt)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(x = "Kredithöhe", y = "Differenz", title = "Darstellung beantragte und tatsächliche Kredithöhe")
# Aus der Grafik lässt sich gut erkennen, dass die Differenz vom geforderten Kredit mit der Höhe des Kredits auch ansteigt.

####################### annual_inc #######################
summary(df$annual_inc)
ggplot(df, aes(annual_inc)) + 
  geom_histogram(aes(y=..density..), bins = 30, color="lightblue", fill="blue") +
  geom_density(alpha=0.2, fill="#FF6666") +
  labs(x = "Jährliches Einkommen", y = "Verteilung", title = "Verteilung des Einkommens")
### Analyse der wichtigsten statistischen Werte:
# - Der Median liegt bei einem Jährlichen Einkommen von 58.000 
# - Der Durchschnitt, nachdem wir oben die 1% der Datzensätze entfernt hatten, ist nun auch näher an dem Median mit 65.524
# - Die 1. und 3. Perzentile gibt an, dass 50% der Einkommen zwischen 40.000 und 81.000 liegen. Hier ist die Verteilung 
#   zwar schon besser als mit den obersten 1% aus dem Ursprungsdatensatz aber noch nach rechts an der X-Achse noch weiter gestreut
#   ähnlich wie bei der Kreditsumme auch (Korrelation?)
###
ggplot(df, aes(x = annual_inc, y = loan_amnt, color = annual_inc)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(x = "Jahreseinkommen", y = "Kredithöhe", title = "Darstellung Jahreseinkommen zur Kredithöhe")
# Hier lässt sich zwar ein Trend erkennen, dass mit einem steigenden Einkommen auch die Kredithöhe steigt, jedoch ist hier
# keine starke Korrelation erkennbar. Vielleicht sieht es bei der Kreditbewertung anders aus?
ggplot(df, aes(x = grade, y = annual_inc, color = grade)) + 
  geom_violin(scale = "area") + 
  labs(x = "Kreditbewertung (Klasse)", y = "Jahreseinkommen", title = "Kreditberwetung vs. Jahreseinkommen")
# Aus der Grafik lässt sich keine Korrelation erkennen. Auch hohe Einkommen können eine schlechte Kreditbewertung erhalten.

####################### grade #######################
summary(df$grade)
ggplot(df, aes(grade)) + 
  geom_histogram(stat="count", bins = 30, color="lightblue", fill="blue")  +
  labs(x = "Kreditkateogie", y = "Anzahl Kredite", title = "Darstellung Verteilung der Kredite auf Kategorien")

for (gr in levels(df$grade)) {
  perc_val = round((nrow(df[df$grade %in% c(gr), ])/nrow(df)) * 100, 2)
  print(paste0("Prozent der Kredite wurden eingestuft in: ", gr, " - ", perc_val , "%"))
}

### Analyse der wichtigsten statistischen Werte:
# - Die meisten Kredite wurden in die Kategorie B eingestuft (Modus)
###
# Die Korrelation von gewährtem Kredit und der Einstufung lässt erkennen, dass die Summe der gewährten Kredite 
# zumeist in den Kategorien A-C liegen
ggplot(df, aes(x = grade, y = funded_amnt, color = grade)) + 
  geom_col() +
  labs(x = "Kreditbewertung", y = "Gewährte Kredithöhe [Summe]", title = "Darstellung Höhe des gewährten Kredits vs. Bewertung")

####################### sub_grade #######################
summary(df$sub_grade)
ggplot(df, aes(sub_grade)) + 
  geom_histogram(stat="count", bins = 30, color="lightblue", fill="blue") +
  labs(x = "Kreditunterkateogie", y = "Anzahl Kredite", title = "Darstellung Verteilung der Kredite auf Unterkategorien")

for (sgr in levels(df$sub_grade)) {
  perc_val = round((nrow(df[df$sub_grade %in% c(sgr), ])/nrow(df)) * 100, 2)
  print(paste0("Prozent der Kredite wurden eingestuft in: ", sgr, " - ", perc_val , "%"))
}

### Analyse der wichtigsten statistischen Werte:
# - Die meisten Kredite wurden in die Kategorie B3 (7.33%) eingestuft (Modus)
###
# Eine Korrelation von Unterkategegorien zu dem Zinssatz lässt sich gut aus der folgenden Grafik erkennen, denn je schlechter
# die Einstufung ist, desto höher ist der Zinssatz:
ggplot(df, aes(x = sub_grade, y = int_rate, color = grade)) + 
  geom_boxplot() +
  labs(x = "Kreditunterkateogie", y = "Zinssatz in %", title = "Darstellung Unterkategorie vs. Zinssatz")



# b.4) Erstellen Sie danach eine Visualisierung, um zu zeigen für welchen „grade“ die 
#      Wahrscheinlichkeit am größten ist, dass der „loan_status“= „Fully Paid“ ist.
# Aus dieser Grafik lässt gut erkennen, dass die Kredite der grade A am wahrscheinlichsten abgezahlt werden.
ggplot(df, aes(x = grade)) +
  geom_bar(aes(fill = loan_status == "Fully Paid")) +
  labs(x = "Kreditbewertung", y = "Anzahl abbezahlte/nicht abbezahlte Kredite", title = "Abbezahlte/Nicht abbezahlte Kredite nach Kategorie")
# Alternativ auch mit ausgerechneten Zahlen:
library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr) 
df_prob_a <- df %>%
  group_by(grade) %>%
  summarize(prob = mean(loan_status == "Fully Paid"))
ggplot(df_prob_a, aes(x = reorder(grade, desc(prob)), y = prob, fill = grade)) +
  geom_col() +
  labs(x = "Kreditkateogie", y = "Wahrscheinlichkeit", title = "Wahrscheinlichkeit eines abbezahlten Kredits nach Kategorie")


# b.5) Erstellen Sie danach eine Visualisierung, um zu zeigen für welchen „prupose“ die 
#      Wahrscheinlichkeit am größten ist, dass der „loan_status“= „Charged Off“ ist.
# Aus dieser Grafik lässt kaum erahnen wo die Wahrscheinlichkeit eines Kredits mit „loan_status“= „Charged Off“ höher ist.
ggplot(df, aes(x = purpose)) +
  geom_bar(aes(fill = loan_status == "Charged Off")) +
  labs(x = "Verwendung", y = "Abbezahlte/nicht abbezahlte Kredite", title = "Abbezahlte/Nicht abbezahlte Kredite nach Verwendung")
# Alternative:
df_prob_b <- df %>%
  group_by(purpose) %>%
  summarize(prob = mean(loan_status == "Charged Off"))
ggplot(df_prob_b, aes(x = reorder(purpose, desc(prob)), y = prob, fill = purpose)) +
  geom_col() +
  labs(x = "Verwendung", y = "Wahrscheinlichkeit", title = "Wahrscheinlichkeit eines nicht abbezahlten Kredits nach Verwendung")

#####################################################################################################



############################### Teilaufgabe 1c): Modellierung #######################################
# c) Nutzen Sie nun einen geeigneten Klassifikationsalgorithmus, um den „loan_status“ 
#    (Zielvariable) möglichste vorherzusagen. Wählen Sie geeignete Merkmale als unabhängige 
#    Variablen aus. Standardisieren Sie die nummerischen Variablen falls notwendig. Erstellen Sie 
#    aus dem Datensatz ein Trainings- und Test-Datenset und geben Sie das Resultat des 
#    trainierten Modells auf dem Testdatensatz in einer Wahrheitsmatrix (Confusion Matrx) aus. 
#    Erklären Sie in Textform (als langen Kommentar im R-Skript), warum Sie den Algorithmus und 
#    die Merkmale ausgewählt haben. 
#####################################################################################################
summary(df)
############################### Spaltenauswahl mit Begründung: ############################################
# Merkmale: id, member_id, url, desc müssen nicht berücksichtigt werden, diese enthalten keinen Mehrwert.
# Merkmale: loan_amnt oder funded_amnt oder funded_amnt_inv > loan_amnt ist hier relevant, da lediglich dieser zum Zeitpunkt
#           einer Kreditanfrage als Information zur Verfügung steht. Andere Werte könnten durch Modell vorhergesagt werden,
#           im Falle einer Absage für die genannte Höhe :-)
# Merkmal:  term (Kreditlaufzeit) ist kein unabhängiges Merkmal, da es von der Kredithöhe und der monatlichen Rate abhängt
#           und somit nicht relevant
# Merkmal:  int_rate - Diese Information steht zum Zeitpunkt der Kreditanfrage nicht zur Verfügung, diese könnte aber in einem
#           weiteren Modell anhand des Risikos bei der Vergabe eines Kredits vorgeschlagen werden.
# Merkmal:  emp_title ist ebenfalls nicht relevant, es ist nicht aussagekräft bzgl. Einkommen/Position
# Merkmal:  emp_length könnte relevant sein, da dies ein Indikator für die finanzielle Stabilität sein kann
# Merkmal:  home_ownership ist ein relevantes Merkmal, dieser lässt auf den finanzielle Status schließen
# Merkmal:  annual_inc - Das Jahreseinkommen ist relevant für die Bestimmung für oder gegen eine Vergabe eines Kredits
# Markmal:  verification_status - Der Verifizierungsstatus kann relevant sein (je nachdem wie und wann der ermittelt wird)
#           z.B. bei einer Kreditanfrage mit Übersendung von Lohndokumenten kann er gleich verifiziert werden > diese Annahme
#           wird zum gegebenen Zeitpunkt getroffen > somit relevantes Feature
# Markmal:  issue_d - Datum der Auszahlung ist nicht relevant - Aus einem Datum kann nicht auf die Kreditwürdigkeit geschlossen werden
# Markmal:  purpose - Relevant, da diese auf einen Gegenwert der Investiton hindeuten können und so die Kreditwürdigkeit
#           positiv oder negativ beeinflussen können, z.B. positiv bei Auto, da ein Gegenwert vorhanden ist. Negativ bei
#           Sonstigen Anschaffungen ohne Wiederverkaufswert
# Markmal:  zip_code - Lage lässt zumeist auf finanziellen Status hindeuten - üblicherweise eine relevante Variable, jedoch ist das 
#           vorhandene Datensetz zu klein um 5stellige ZIP Codes in einer genügenden Anzahl vorzuhalten. Die Bank schwärzt die letzten
#           beiden Zahlen aus, somit ist keine genaue Position ermittelbar und somit auch nicht aussagekräftig für unseren Anwendungsfall
# Markmal:  addr_state ist Abhängig zum ZIP Code und wird nicht herangezogen
# Markmal:  dti - keine unabhängige Variable, Abhängigkeit zur Kreditsumme und des Einkommens gegeben 
# Markmal:  earliest_cr_line - nicht relevant, da zeitliche Angaben keine direkte Auswirkung auf eine Kreditwürdigkeit hat
# Markmal:  inq_last_6mths - relevant, da eine hohe Anzahl an Kreditanfragen darauf hindeuten könnte, dass die Person
#           Probleme hat einen Kredit zu beschaffen, das könnte negative Auswirkungen auf die Kreditwürdigkeit haben
# Markmal:  open_acc - relevant, da eine hohe Anzahl an bereits bestehenden Krediten darauf hindeuten könnte, dass die Person
#           finanziell nicht gut aufgestellt ist.
# Markmale: revol_bal & revol_util - Abhängigkeit zum purpose/loan gegeben, da revolvierende Kreditsalden zumeinst durch 
#           Kreditkartengebrauch entstehen
# Markmal:  total_acc - Abhängigkeit zu open_acc gegeben, es ist leider nicht ersichtlich ob die in der Vergangenheit
#           liegenden Kredite vollständig zurückgezahlt wurden, sonst könnte man ein neues Feature daraus generieren.
# Markmale: total_pymnt, total_pymnt_inv, total_rec_prncp, total_rec_int, last_pymnt_d, last_pymnt_amnt, next_pymnt_d und
#           last_credit_pull_d - nicht zum Zeitpunkt der Kreditanfrage bekannt > nicht relevant.

# emp_length umwandeln in eine kategorische Variable
# home_ownership als dummy umwandeln

dfm <- subset(df, select = c(loan_status, loan_amnt, emp_length, home_ownership, annual_inc, verification_status, purpose, +
                             inq_last_6mths, open_acc))

# Umwandlung emp_length in eine Zahl
table(dfm$emp_length)
# Auffälligkeit: "n/a" als Text vorhanden, diese Zeilen werden gelöscht, keine signifikante Menge:
dfm <- dfm[dfm$emp_length != "n/a", ]
# Umwandlung der Angestelltendauer in eine Skala von 0 - 10
dfm <- dfm %>%
  mutate(emp_length = ifelse(emp_length == "< 1 year", 0,
				     ifelse(emp_length == "1 year", 1,
			    	     		ifelse(emp_length == "10+ years", 10,
							 gsub(" years", "", emp_length)))))
table(dfm$emp_length)

# Umwandlung loan_status einer binären Enscheidungsvariable (Label)
table(dfm$loan_status)
# Auffälligkeit: Es gibt noch offenen Kredite in dem Datensatz, diese müssten vorher gelöscht werden, da diese keine Aussage über
#                den Status "Fully Paid" bzw. "Charged Off" haben.
dfm <- dfm[dfm$loan_status != "Current", ]
table(dfm$loan_status)
dfm <- dfm %>%
  mutate(loan_status = ifelse(loan_status == "Fully Paid", 1,
					0))
table(dfm$loan_status)
# 1 = Paid (positiv Fall)
# 0 = Charged Off (negativer Fall)
						   
# Umwandlung home_ownership zu einer kategorischen Variable
table(dfm$home_ownership)
# Auffälligkeit: "NONE" als Text drei mal vorhanden, diese werden gelöscht (kein signifikanter Unterschied):
dfm <- dfm[dfm$home_ownership != "NONE", ]
dfm$home_ownership <- as.factor(dfm$home_ownership)
table(dfm$home_ownership)


paste0("Anzahl der ausgewählten Features: ", ncol(dfm)-1)
paste0("Anzahl Datensätze für Modellierung: ", nrow(dfm))

################################ Wahl des Modells mit Begründung ##############################################
# Logistische Regression
# Die Logistische Regression ist ein statistisches Modell, das dafür verwendet wird, die Wahrscheinlichkeit zu schätzen, 
# dass ein bestimmtes Ereignis eintritt (in diesem Fall die Rückzahlung eines Kredits). Die Features, die bereitstehen (Kredithöhe, 
# Anstellungsdauer, Angabe zum Wohnverhältnis, Postleitzahl, usw.) können als Eingabevariablen in das Modell einbezogen werden, 
# um die Wahrscheinlichkeit zu schätzen, dass ein Kredit zurück gezahlt wird. Es eignet sich gut für binäre Entscheidungen.
# Deswegen fällt meine Wahl für das zugrunde liegende Problem auf die Logistische Regression, ein weiteres Modell wäre der Entscheidungsbaum
# aus dem Pool der Klassifizierungsmodelle.
###############################################################################################################
library(stats)
library(caret)
library(caTools)

# Setzen eines Seed, um reproduzierbare Ergebnisse zu gewährleisten
set.seed(101)  

# Split definieren für Trainingsdaten
split <- sample.split(dfm, SplitRatio = 0.7)

# Trainsingsdaten und Testdaten festlegen
# X-Datensets enthalten jeweils das Label als Spalte "loan_status"
train <- dfm[split, ]
test <- dfm[!split, ]

paste0("Größe Trainingsdatensatz: ", nrow(train))
paste0("Größe Testdatensatz: ", nrow(test))

# Training des Modells
model <- glm(loan_status ~ ., data = train, family = "binomial")

# Predictions
pred <- predict(model, test, type="response")
# Richtigen Fit finden
summary(pred)
# Die Justierung kann von der Bank vorgegeben werden, hiermit kann entschieden werden wie viel Risiko akzeptiert wird und ein Kredit
# doch noch vergeben wird aber jeweils mit einem höheren Zinssatz zum Beispiel um das Risiko entsprechend abzufedern. 
pred <- as.data.frame(ifelse(pred >0.75, 1, 0))
# Ich habe hier mit einigen Werte rum gespielt: 
# Bei 0.6 werden zum Beispiel zu viele Kredite vergeben, die hätten lieber nicht vergeben werden sollen 
#    Fehleinschätzungen (laut Confusion Matrix) lag bei 1760 (fälschlicherweise gewährt) + 25 (fälschlicherweise abgelehnt)
# Bei 0.75 hier werden weniger Kredite fälschlicherweise gewährt, jedoch mehr abgelegt (Einnahmeverluste)
#    Fehleinschätzungen (laut Confusion Matrix) lag bei 1566 (fälschlicherweise gewährt) + 472 (fälschlicherweise abgelehnt) 
# Bei 0.9 werden zu wenige Kredite vergeben, die hätten aber lieber vergeben werden sollen. 
#    Fehleinschätzungen (laut Confusion Matrix) lag bei 239 (fälschlicherweise gewährt) + 7930 (fälschlicherweise abgelehnt) (!!!)

x <- c("loan_status")
colnames(pred) <- x

# ConfusionMatrix
confusionMatrix(as.factor(test$loan_status), as.factor(pred$loan_status))


