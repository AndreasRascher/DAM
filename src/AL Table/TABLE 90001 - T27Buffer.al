table 90001 T27Buffer
{
    CaptionML= DEU = 'Artikel', ENU='Item';
  fields {
        field(1; "No."; Code[20])
        {
            CaptionML = ENU = 'No.', DEU = 'Nr.';
        }
        field(2; "No. 2"; Code[20])
        {
            CaptionML = ENU = 'No. 2', DEU = 'Nummer 2';
        }
        field(3; "Description"; Text[30])
        {
            CaptionML = ENU = 'Description', DEU = 'Beschreibung';
        }
        field(4; "Search Description"; Code[30])
        {
            CaptionML = ENU = 'Search Description', DEU = 'Suchbegriff';
        }
        field(5; "Description 2"; Text[30])
        {
            CaptionML = ENU = 'Description 2', DEU = 'Beschreibung 2';
        }
        field(8; "Base Unit of Measure"; Code[10])
        {
            CaptionML = ENU = 'Base Unit of Measure', DEU = 'Basiseinheitencode';
        }
        field(9; "Price Unit Conversion"; Integer)
        {
            CaptionML = ENU = 'Price Unit Conversion', DEU = 'Preisfaktor';
        }
        field(11; "Inventory Posting Group"; Code[10])
        {
            CaptionML = ENU = 'Inventory Posting Group', DEU = 'Lagerbuchungsgruppe';
        }
        field(12; "Shelf No."; Code[10])
        {
            CaptionML = ENU = 'Shelf No.', DEU = 'Regalnr.';
        }
        field(14; "Item Disc. Group"; Code[10])
        {
            CaptionML = ENU = 'Item Disc. Group', DEU = 'Artikelrabattgruppe';
        }
        field(15; "Allow Invoice Disc."; Boolean)
        {
            CaptionML = ENU = 'Allow Invoice Disc.', DEU = 'Rech.-Rabatt zulassen';
        }
        field(16; "Statistics Group"; Integer)
        {
            CaptionML = ENU = 'Statistics Group', DEU = 'Statistikgruppe';
        }
        field(17; "Commission Group"; Integer)
        {
            CaptionML = ENU = 'Commission Group', DEU = 'Provisionsgruppe';
        }
        field(18; "Unit Price"; Decimal)
        {
            CaptionML = ENU = 'Unit Price', DEU = 'VK-Preis';
        }
        field(19; "Price/Profit Calculation"; Option)
        {
            CaptionML = ENU = 'Price/Profit Calculation', DEU = 'VK-Preis/DB - Berechnung';
          OptionMembers = "Profit=Price-Cost","Price=Cost+Profit","No Relationship";
          OptionCaptionML = ENU = 'Profit=Price-Cost,Price=Cost+Profit,No Relationship', DEU = 'DB = VK - EP,VK = EP + DB,kein Bezug';
        }
        field(20; "Profit %"; Decimal)
        {
            CaptionML = ENU = 'Profit %', DEU = 'DB %';
        }
        field(21; "Costing Method"; Option)
        {
            CaptionML = ENU = 'Costing Method', DEU = 'Lagerabgangsmethode';
          OptionMembers = FIFO,LIFO,Specific,Average,Standard;
          OptionCaptionML = ENU = 'FIFO,LIFO,Specific,Average,Standard', DEU = 'FIFO,LIFO,Ausgewählt,Durchschnitt,Standard';
        }
        field(22; "Unit Cost"; Decimal)
        {
            CaptionML = ENU = 'Unit Cost', DEU = 'Einstandspreis';
        }
        field(24; "Standard Cost"; Decimal)
        {
            CaptionML = ENU = 'Standard Cost', DEU = 'Einstandspreis (fest)';
        }
        field(25; "Last Direct Cost"; Decimal)
        {
            CaptionML = ENU = 'Last Direct Cost', DEU = 'EK-Preis (neuester)';
        }
        field(28; "Indirect Cost %"; Decimal)
        {
            CaptionML = ENU = 'Indirect Cost %', DEU = 'Kosten %';
        }
        field(29; "Cost is Adjusted"; Boolean)
        {
            CaptionML = ENU = 'Cost is Adjusted', DEU = 'Einstandspreis ist reguliert';
        }
        field(30; "Allow Online Adjustment"; Boolean)
        {
            CaptionML = ENU = 'Allow Online Adjustment', DEU = 'Onlineregulierung zulassen';
        }
        field(31; "Vendor No."; Code[20])
        {
            CaptionML = ENU = 'Vendor No.', DEU = 'Kreditorennr.';
        }
        field(32; "Vendor Item No."; Text[20])
        {
            CaptionML = ENU = 'Vendor Item No.', DEU = 'Kred.-Artikelnr.';
        }
        field(33; "Lead Time Calculation"; DateFormula)
        {
            CaptionML = ENU = 'Lead Time Calculation', DEU = 'Beschaffungszeit';
        }
        field(34; "Reorder Point"; Decimal)
        {
            CaptionML = ENU = 'Reorder Point', DEU = 'Minimalbestand';
        }
        field(35; "Maximum Inventory"; Decimal)
        {
            CaptionML = ENU = 'Maximum Inventory', DEU = 'Maximalbestand';
        }
        field(36; "Reorder Quantity"; Decimal)
        {
            CaptionML = ENU = 'Reorder Quantity', DEU = 'Bestellmenge';
        }
        field(37; "Alternative Item No."; Code[20])
        {
            CaptionML = ENU = 'Alternative Item No.', DEU = 'Alternative Artikelnr.';
        }
        field(38; "Unit List Price"; Decimal)
        {
            CaptionML = ENU = 'Unit List Price', DEU = 'Richtpreis';
        }
        field(39; "Duty Due %"; Decimal)
        {
            CaptionML = ENU = 'Duty Due %', DEU = 'Abgabenteil %';
        }
        field(40; "Duty Code"; Code[10])
        {
            CaptionML = ENU = 'Duty Code', DEU = 'Abgabencode';
        }
        field(41; "Gross Weight"; Decimal)
        {
            CaptionML = ENU = 'Gross Weight', DEU = 'Bruttogewicht';
        }
        field(42; "Net Weight"; Decimal)
        {
            CaptionML = ENU = 'Net Weight', DEU = 'Nettogewicht';
        }
        field(43; "Units per Parcel"; Decimal)
        {
            CaptionML = ENU = 'Units per Parcel', DEU = 'Anzahl pro Paket';
        }
        field(44; "Unit Volume"; Decimal)
        {
            CaptionML = ENU = 'Unit Volume', DEU = 'Volumen';
        }
        field(45; "Durability"; Code[10])
        {
            CaptionML = ENU = 'Durability', DEU = 'Haltbarkeit';
        }
        field(46; "Freight Type"; Code[10])
        {
            CaptionML = ENU = 'Freight Type', DEU = 'Frachtform';
        }
        field(47; "Tariff No."; Code[10])
        {
            CaptionML = ENU = 'Tariff No.', DEU = 'Zollpos.';
        }
        field(48; "Duty Unit Conversion"; Decimal)
        {
            CaptionML = ENU = 'Duty Unit Conversion', DEU = 'Zollfaktor';
        }
        field(49; "Country/Region Purchased Code"; Code[10])
        {
            CaptionML = ENU = 'Country/Region Purchased Code', DEU = 'Herkunftsland/-region';
        }
        field(50; "Budget Quantity"; Decimal)
        {
            CaptionML = ENU = 'Budget Quantity', DEU = 'Budgetierte Menge';
        }
        field(51; "Budgeted Amount"; Decimal)
        {
            CaptionML = ENU = 'Budgeted Amount', DEU = 'Budgetierter Betrag';
        }
        field(52; "Budget Profit"; Decimal)
        {
            CaptionML = ENU = 'Budget Profit', DEU = 'Budgetierter DB';
        }
        field(54; "Blocked"; Boolean)
        {
            CaptionML = ENU = 'Blocked', DEU = 'Gesperrt';
        }
        field(62; "Last Date Modified"; Date)
        {
            CaptionML = ENU = 'Last Date Modified', DEU = 'Korrigiert am';
        }
        field(87; "Price Includes VAT"; Boolean)
        {
            CaptionML = ENU = 'Price Includes VAT', DEU = 'VK-Preis inkl. MwSt.';
        }
        field(90; "VAT Bus. Posting Gr. (Price)"; Code[10])
        {
            CaptionML = ENU = 'VAT Bus. Posting Gr. (Price)', DEU = 'MwSt.-Geschäftsbuch.-G.(Preis)';
        }
        field(91; "Gen. Prod. Posting Group"; Code[10])
        {
            CaptionML = ENU = 'Gen. Prod. Posting Group', DEU = 'Produktbuchungsgruppe';
        }
        field(95; "Country/Region of Origin Code"; Code[10])
        {
            CaptionML = ENU = 'Country/Region of Origin Code', DEU = 'Ursprungsland/-region';
        }
        field(96; "Automatic Ext. Texts"; Boolean)
        {
            CaptionML = ENU = 'Automatic Ext. Texts', DEU = 'Automat. Textbaustein';
        }
        field(97; "No. Series"; Code[10])
        {
            CaptionML = ENU = 'No. Series', DEU = 'Nummernserie';
        }
        field(98; "Tax Group Code"; Code[10])
        {
            CaptionML = ENU = 'Tax Group Code', DEU = 'Steuergruppencode';
        }
        field(99; "VAT Prod. Posting Group"; Code[10])
        {
            CaptionML = ENU = 'VAT Prod. Posting Group', DEU = 'MwSt.-Produktbuchungsgruppe';
        }
        field(100; "Reserve"; Option)
        {
            CaptionML = ENU = 'Reserve', DEU = 'Reservieren';
          OptionMembers = Never,Optional,Always;
          OptionCaptionML = ENU = 'Never,Optional,Always', DEU = 'Nie,Optional,Immer';
        }
        field(105; "Global Dimension 1 Code"; Code[20])
        {
            CaptionML = ENU = 'Global Dimension 1 Code', DEU = 'Globaler Dimensionscode 1';
        }
        field(106; "Global Dimension 2 Code"; Code[20])
        {
            CaptionML = ENU = 'Global Dimension 2 Code', DEU = 'Globaler Dimensionscode 2';
        }
        field(5400; "Low-Level Code"; Integer)
        {
            CaptionML = ENU = 'Low-Level Code', DEU = 'Stücklistenebene';
        }
        field(5401; "Lot Size"; Decimal)
        {
            CaptionML = ENU = 'Lot Size', DEU = 'Losgröße';
        }
        field(5402; "Serial Nos."; Code[10])
        {
            CaptionML = ENU = 'Serial Nos.', DEU = 'Seriennummern';
        }
        field(5403; "Last Unit Cost Calc. Date"; Date)
        {
            CaptionML = ENU = 'Last Unit Cost Calc. Date', DEU = 'Datum letzte Einst.-Preisber.';
        }
        field(5404; "Rolled-up Material Cost"; Decimal)
        {
            CaptionML = ENU = 'Rolled-up Material Cost', DEU = 'Mehrstufige Materialkosten';
        }
        field(5405; "Rolled-up Capacity Cost"; Decimal)
        {
            CaptionML = ENU = 'Rolled-up Capacity Cost', DEU = 'Mehrstufige Kapazitätskosten';
        }
        field(5407; "Scrap %"; Decimal)
        {
            CaptionML = ENU = 'Scrap %', DEU = 'Ausschuss %';
        }
        field(5409; "Inventory Value Zero"; Boolean)
        {
            CaptionML = ENU = 'Inventory Value Zero', DEU = 'Ohne Lagerbewertung';
        }
        field(5410; "Discrete Order Quantity"; Integer)
        {
            CaptionML = ENU = 'Discrete Order Quantity', DEU = 'Anzahl Zyklen zusammenfassen';
        }
        field(5411; "Minimum Order Quantity"; Decimal)
        {
            CaptionML = ENU = 'Minimum Order Quantity', DEU = 'Minimale Losgröße';
        }
        field(5412; "Maximum Order Quantity"; Decimal)
        {
            CaptionML = ENU = 'Maximum Order Quantity', DEU = 'Maximale Losgröße';
        }
        field(5413; "Safety Stock Quantity"; Decimal)
        {
            CaptionML = ENU = 'Safety Stock Quantity', DEU = 'Sicherheitsbestand';
        }
        field(5414; "Order Multiple"; Decimal)
        {
            CaptionML = ENU = 'Order Multiple', DEU = 'Losgrößenrundungsfaktor';
        }
        field(5415; "Safety Lead Time"; DateFormula)
        {
            CaptionML = ENU = 'Safety Lead Time', DEU = 'Sicherh.-Zuschl. Beschaff.-Zt.';
        }
        field(5417; "Flushing Method"; Option)
        {
            CaptionML = ENU = 'Flushing Method', DEU = 'Buchungsmethode';
          OptionMembers = Manual,Forward,Backward,"Pick + Forward","Pick + Backward";
          OptionCaptionML = ENU = 'Manual,Forward,Backward,Pick + Forward,Pick + Backward', DEU = 'Manuell,Vorwärts,Rückwärts,Kommiss. + Vorwärts,Kommiss. + Rückwärts';
        }
        field(5419; "Replenishment System"; Option)
        {
            CaptionML = ENU = 'Replenishment System', DEU = 'Beschaffungsmethode';
          OptionMembers = Purchase,"Prod. Order"," ";
          OptionCaptionML = ENU = 'Purchase,Prod. Order, ', DEU = 'Einkauf,Fertigungsauftrag, ';
        }
        field(5422; "Rounding Precision"; Decimal)
        {
            CaptionML = ENU = 'Rounding Precision', DEU = 'Rundungspräzision';
        }
        field(5425; "Sales Unit of Measure"; Code[10])
        {
            CaptionML = ENU = 'Sales Unit of Measure', DEU = 'Verkaufseinheitencode';
        }
        field(5426; "Purch. Unit of Measure"; Code[10])
        {
            CaptionML = ENU = 'Purch. Unit of Measure', DEU = 'Einkaufseinheitencode';
        }
        field(5428; "Reorder Cycle"; DateFormula)
        {
            CaptionML = ENU = 'Reorder Cycle', DEU = 'Bestellzyklus';
        }
        field(5440; "Reordering Policy"; Option)
        {
            CaptionML = ENU = 'Reordering Policy', DEU = 'Wiederbeschaffungsverfahren';
          OptionMembers = " ","Fixed Reorder Qty.","Maximum Qty.",Order,"Lot-for-Lot";
          OptionCaptionML = ENU = ' ,Fixed Reorder Qty.,Maximum Qty.,Order,Lot-for-Lot', DEU = ' ,Feste Bestellmenge,Auffüllen auf Maximalbestand,Auftragsmenge,Los-für-Los';
        }
        field(5441; "Include Inventory"; Boolean)
        {
            CaptionML = ENU = 'Include Inventory', DEU = 'Lagerbestand berücksichtigen';
        }
        field(5442; "Manufacturing Policy"; Option)
        {
            CaptionML = ENU = 'Manufacturing Policy', DEU = 'Produktionsart';
          OptionMembers = "Make-to-Stock","Make-to-Order";
          OptionCaptionML = ENU = 'Make-to-Stock,Make-to-Order', DEU = 'Lagerfertigung,Auftragsfertigung';
        }
        field(5701; "Manufacturer Code"; Code[10])
        {
            CaptionML = ENU = 'Manufacturer Code', DEU = 'Herstellercode';
        }
        field(5702; "Item Category Code"; Code[10])
        {
            CaptionML = ENU = 'Item Category Code', DEU = 'Artikelkategoriencode';
        }
        field(5703; "Created From Nonstock Item"; Boolean)
        {
            CaptionML = ENU = 'Created From Nonstock Item', DEU = 'Aus Katalogartikel erstellt';
        }
        field(5704; "Product Group Code"; Code[10])
        {
            CaptionML = ENU = 'Product Group Code', DEU = 'Produktgruppencode';
        }
        field(5900; "Service Item Group"; Code[10])
        {
            CaptionML = ENU = 'Service Item Group', DEU = 'Serviceartikelgruppe';
        }
        field(6500; "Item Tracking Code"; Code[10])
        {
            CaptionML = ENU = 'Item Tracking Code', DEU = 'Artikelverfolgungscode';
        }
        field(6501; "Lot Nos."; Code[10])
        {
            CaptionML = ENU = 'Lot Nos.', DEU = 'Chargennummern';
        }
        field(6502; "Expiration Calculation"; DateFormula)
        {
            CaptionML = ENU = 'Expiration Calculation', DEU = 'Ablaufdatumsformel';
        }
        field(7301; "Special Equipment Code"; Code[10])
        {
            CaptionML = ENU = 'Special Equipment Code', DEU = 'Lagerhilfsmittelcode';
        }
        field(7302; "Put-away Template Code"; Code[10])
        {
            CaptionML = ENU = 'Put-away Template Code', DEU = 'Einlagerungsvorlagencode';
        }
        field(7307; "Put-away Unit of Measure Code"; Code[10])
        {
            CaptionML = ENU = 'Put-away Unit of Measure Code', DEU = 'Einlagerungseinheitencode';
        }
        field(7380; "Phys Invt Counting Period Code"; Code[10])
        {
            CaptionML = ENU = 'Phys Invt Counting Period Code', DEU = 'Inventurhäufigkeitscode';
        }
        field(7381; "Last Counting Period Update"; Date)
        {
            CaptionML = ENU = 'Last Counting Period Update', DEU = 'Letzte Aktual. Inv.-Häufigkeit';
        }
        field(7382; "Next Counting Period"; Text[250])
        {
            CaptionML = ENU = 'Next Counting Period', DEU = 'Nächstes Inventurdatum';
        }
        field(7384; "Use Cross-Docking"; Boolean)
        {
            CaptionML = ENU = 'Use Cross-Docking', DEU = 'Zuordnung verwenden';
        }
        field(50000; "Commission Category"; Code[20])
        {
            CaptionML = ENU = 'Commission Category', DEU = 'Provisionsgruppe';
        }
        field(50001; "Commission Type"; Option)
        {
            CaptionML = ENU = 'Commission Type', DEU = 'Provisionsart';
          OptionMembers = Amount,Quantity;
          OptionCaptionML = ENU = 'Amount,Quantity', DEU = 'Nach Betrag,Nach Menge';
        }
        field(50003; "Allow Line Disc."; Boolean)
        {
            CaptionML = ENU = 'Allow Line Disc.', DEU = 'Zeilenrabatt zulassen';
        }
        field(50006; "Bonus qualified"; Boolean)
        {
            CaptionML = ENU = 'Bonus qualified', DEU = 'Bonusfähig';
        }
        field(50007; "Price Unit Purchase"; Code[10])
        {
            CaptionML = ENU = 'Price Unit Purchase', DEU = 'EK Preiseinheit';
        }
        field(50008; "Price Unit Sales"; Code[10])
        {
            CaptionML = ENU = 'Price Unit Sales', DEU = 'VK Preiseinheit';
        }
        field(50009; "Price Unit Purchase Quantity"; Decimal)
        {
            CaptionML = ENU = 'Price Unit Purchase Quantity', DEU = 'EK Preiseinheit Menge';
        }
        field(50010; "Price Unit Sales Quantity"; Decimal)
        {
            CaptionML = ENU = 'Price Unit Sales Quantity', DEU = 'VK Preiseinheit Menge';
        }
        field(50011; "Price Group"; Code[10])
        {
            CaptionML = ENU = 'Price Group', DEU = 'Preis Gruppe';
        }
        field(50012; "Production Unit of Measure"; Code[10])
        {
            CaptionML = ENU = 'Production Unit of Measure', DEU = 'Fertigungseinheitencode';
        }
        field(50026; "Blocked for Order"; Boolean)
        {
            CaptionML = ENU = 'Blocked for Order', DEU = 'Gesperrt für Auftrag';
        }
        field(50050; "QS Check"; Boolean)
        {
            CaptionML = ENU = 'QS Check', DEU = 'QS Prüfung';
        }
        field(50073; "Package (Y/N)"; Boolean)
        {
            CaptionML = ENU = 'Package (Y/N)', DEU = 'Packmittel (J/N)';
        }
        field(50074; "Tray"; Code[30])
        {
            CaptionML = ENU = 'Tray', DEU = 'Tablett';
        }
        field(50075; "Knife"; Code[30])
        {
            CaptionML = ENU = 'Knife', DEU = 'Messer';
        }
        field(50076; "Knife Sharpener"; Code[30])
        {
            CaptionML = ENU = 'Knife Sharpener', DEU = 'Messerschärfer';
        }
        field(50077; "Knife Case"; Code[30])
        {
            CaptionML = ENU = 'Knife Case', DEU = 'Messerkassette';
        }
        field(50078; "Sledge"; Code[30])
        {
            CaptionML = ENU = 'Sledge', DEU = 'Schlitten';
        }
        field(50079; "Volt/Hz."; Code[30])
        {
            CaptionML = ENU = 'Volt/Hz.', DEU = 'Volt/Hz.';
        }
        field(50080; "Colour"; Code[30])
        {
            CaptionML = ENU = 'Colour', DEU = 'Farbe';
        }
        field(50083; "Old Item No."; Text[30])
        {
            CaptionML = ENU = 'Old Item No.', DEU = 'Alte Artikelnummer';
        }
        field(50084; "Application 1"; Text[50])
        {
            CaptionML = ENU = 'Application 1', DEU = 'Verwendung 1';
        }
        field(50085; "Application 2"; Text[50])
        {
            CaptionML = ENU = 'Application 2', DEU = 'Verwendung 2';
        }
        field(50086; "Special Equipment"; Text[50])
        {
            CaptionML = ENU = 'Special Equipment', DEU = 'Sonderausstattung';
        }
        field(50087; "Electronics"; Text[50])
        {
            CaptionML = ENU = 'Electronics', DEU = 'Elektronik';
        }
        field(50088; "Drawing No. Graef"; Text[30])
        {
            CaptionML = ENU = 'Drawing No. Graef', DEU = 'Zeichnungs Nr. Graef';
        }
        field(50089; "Surcharge Item"; Boolean)
        {
            CaptionML = ENU = 'Surcharge Item', DEU = 'Zuschlagartikel';
        }
        field(50092; "No Commission"; Boolean)
        {
            CaptionML = ENU = 'No Commission', DEU = 'Keine Provision';
        }
        field(50094; "Business Domain"; Option)
        {
            CaptionML = ENU = 'Business Domain', DEU = 'Geschäftsbereich';
          OptionMembers = Consumer,Professional,"Service-Con.","Service-Prof.";
          OptionCaptionML = ENU = 'Consumer,Professional,Service-Con.,Service-Prof.', DEU = 'Consumer,Professional,Service-Con.,Service-Prof.';
        }
        field(50095; "Class of Goods"; Code[10])
        {
            CaptionML = ENU = 'Class of Goods', DEU = 'Warengruppe';
        }
        field(50096; "Item Class"; Code[10])
        {
            CaptionML = ENU = 'Item Class', DEU = 'Artikelgruppe';
        }
        field(50097; "Product Class"; Code[10])
        {
            CaptionML = ENU = 'Product Class', DEU = 'Produktgruppe';
        }
        field(50104; "Long term suppliers decl."; Boolean)
        {
            CaptionML = ENU = 'Long term suppliers decl.', DEU = 'Langzeitlieferantenerklärung';
        }
        field(50105; "Information"; Text[50])
        {
            CaptionML = ENU = 'Information', DEU = 'Information';
        }
        field(87000; "Item GTIN"; Code[20])
        {
            CaptionML = ENU = 'Item GTIN', DEU = 'Artikel GTIN';
        }
        field(87001; "Deb-Cred Code"; Code[10])
        {
            CaptionML = ENU = 'Deb-Cred Code', DEU = 'Zu- Abschlagscode';
        }
        field(87002; "Consumption UoM"; Code[10])
        {
            CaptionML = ENU = 'Consumption UoM', DEU = 'Verbrauchseinheit';
        }
        field(87003; "Diff. GTIN-Type"; Code[10])
        {
            CaptionML = ENU = 'Diff. GTIN-Type', DEU = 'Abw. GTIN-Art';
        }
        field(99000750; "Routing No."; Code[20])
        {
            CaptionML = ENU = 'Routing No.', DEU = 'Arbeitsplannr.';
        }
        field(99000751; "Production BOM No."; Code[20])
        {
            CaptionML = ENU = 'Production BOM No.', DEU = 'Fert.-Stücklistennr.';
        }
        field(99000752; "Single-Level Material Cost"; Decimal)
        {
            CaptionML = ENU = 'Single-Level Material Cost', DEU = 'Einstufige Materialkosten';
        }
        field(99000753; "Single-Level Capacity Cost"; Decimal)
        {
            CaptionML = ENU = 'Single-Level Capacity Cost', DEU = 'Einstufige Kapazitätskosten';
        }
        field(99000754; "Single-Level Subcontrd. Cost"; Decimal)
        {
            CaptionML = ENU = 'Single-Level Subcontrd. Cost', DEU = 'Einstufige Fremdarbeitskosten';
        }
        field(99000755; "Single-Level Cap. Ovhd Cost"; Decimal)
        {
            CaptionML = ENU = 'Single-Level Cap. Ovhd Cost', DEU = 'Einstufige Kap.-Gemeinkosten';
        }
        field(99000756; "Single-Level Mfg. Ovhd Cost"; Decimal)
        {
            CaptionML = ENU = 'Single-Level Mfg. Ovhd Cost', DEU = 'Einstufige Prod.-Gemeinkosten';
        }
        field(99000757; "Overhead Rate"; Decimal)
        {
            CaptionML = ENU = 'Overhead Rate', DEU = 'Gemeinkostensatz';
        }
        field(99000758; "Rolled-up Subcontracted Cost"; Decimal)
        {
            CaptionML = ENU = 'Rolled-up Subcontracted Cost', DEU = 'Mehrstufige Fremdarbeitskosten';
        }
        field(99000759; "Rolled-up Mfg. Ovhd Cost"; Decimal)
        {
            CaptionML = ENU = 'Rolled-up Mfg. Ovhd Cost', DEU = 'Mehrstufige Prod.-Gemeinkosten';
        }
        field(99000760; "Rolled-up Cap. Overhead Cost"; Decimal)
        {
            CaptionML = ENU = 'Rolled-up Cap. Overhead Cost', DEU = 'Mehrstufige Kap.-Gemeinkosten';
        }
        field(99000773; "Order Tracking Policy"; Option)
        {
            CaptionML = ENU = 'Order Tracking Policy', DEU = 'Bedarfsverursacherart';
          OptionMembers = None,"Tracking Only","Tracking & Action Msg.";
          OptionCaptionML = ENU = 'None,Tracking Only,Tracking & Action Msg.', DEU = 'Keine,Nur Bedarfsverursacher,Bedarfsverurs. & Ereignismeld.';
        }
        field(99000875; "Critical"; Boolean)
        {
            CaptionML = ENU = 'Critical', DEU = 'Kritisch';
        }
        field(99008500; "Common Item No."; Code[20])
        {
            CaptionML = ENU = 'Common Item No.', DEU = 'Gemeinsame Artikelnr.';
        }
  }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
