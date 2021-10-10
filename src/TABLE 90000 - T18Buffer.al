table 90000 T18Buffer
{
    CaptionML= DEU = 'Debitor', ENU = 'Customer';
  fields {
        field(1; "No."; Code[20])
        {
            CaptionML = ENU = 'No.', DEU = 'Nr.';
        }
        field(2; "Name"; Text[50])
        {
            CaptionML = ENU = 'Name', DEU = 'Name';
        }
        field(3; "Search Name"; Code[50])
        {
            CaptionML = ENU = 'Search Name', DEU = 'Suchbegriff';
        }
        field(4; "Name 2"; Text[50])
        {
            CaptionML = ENU = 'Name 2', DEU = 'Name 2';
        }
        field(5; "Address"; Text[50])
        {
            CaptionML = ENU = 'Address', DEU = 'Adresse';
        }
        field(6; "Address 2"; Text[50])
        {
            CaptionML = ENU = 'Address 2', DEU = 'Adresse 2';
        }
        field(7; "City"; Text[30])
        {
            CaptionML = ENU = 'City', DEU = 'Ort';
        }
        field(8; "Contact"; Text[50])
        {
            CaptionML = ENU = 'Contact', DEU = 'Kontakt';
        }
        field(9; "Phone No."; Text[30])
        {
            CaptionML = ENU = 'Phone No.', DEU = 'Telefonnr.';
        }
        field(10; "Telex No."; Text[20])
        {
            CaptionML = ENU = 'Telex No.', DEU = 'Telexnr.';
        }
        field(14; "Our Account No."; Text[20])
        {
            CaptionML = ENU = 'Our Account No.', DEU = 'Unsere Kontonr.';
        }
        field(15; "Territory Code"; Code[10])
        {
            CaptionML = ENU = 'Territory Code', DEU = 'Gebietscode';
        }
        field(16; "Global Dimension 1 Code"; Code[20])
        {
            CaptionML = ENU = 'Global Dimension 1 Code', DEU = 'Globaler Dimensionscode 1';
        }
        field(17; "Global Dimension 2 Code"; Code[20])
        {
            CaptionML = ENU = 'Global Dimension 2 Code', DEU = 'Globaler Dimensionscode 2';
        }
        field(18; "Chain Name"; Code[10])
        {
            CaptionML = ENU = 'Chain Name', DEU = 'Unternehmenskette';
        }
        field(19; "Budgeted Amount"; Decimal)
        {
            CaptionML = ENU = 'Budgeted Amount', DEU = 'Budgetierter Betrag';
        }
        field(20; "Credit Limit (LCY)"; Decimal)
        {
            CaptionML = ENU = 'Credit Limit (LCY)', DEU = 'Kreditlimit (MW)';
        }
        field(21; "Customer Posting Group"; Code[10])
        {
            CaptionML = ENU = 'Customer Posting Group', DEU = 'Debitorenbuchungsgruppe';
        }
        field(22; "Currency Code"; Code[10])
        {
            CaptionML = ENU = 'Currency Code', DEU = 'Währungscode';
        }
        field(23; "Customer Price Group"; Code[10])
        {
            CaptionML = ENU = 'Customer Price Group', DEU = 'Debitorenpreisgruppe';
        }
        field(24; "Language Code"; Code[10])
        {
            CaptionML = ENU = 'Language Code', DEU = 'Sprachcode';
        }
        field(26; "Statistics Group"; Integer)
        {
            CaptionML = ENU = 'Statistics Group', DEU = 'Statistikgruppe';
        }
        field(27; "Payment Terms Code"; Code[10])
        {
            CaptionML = ENU = 'Payment Terms Code', DEU = 'Zlg.-Bedingungscode';
        }
        field(28; "Fin. Charge Terms Code"; Code[10])
        {
            CaptionML = ENU = 'Fin. Charge Terms Code', DEU = 'Zinskonditionencode';
        }
        field(29; "Salesperson Code"; Code[10])
        {
            CaptionML = ENU = 'Salesperson Code', DEU = 'Verkäufercode';
        }
        field(30; "Shipment Method Code"; Code[10])
        {
            CaptionML = ENU = 'Shipment Method Code', DEU = 'Lieferbedingungscode';
        }
        field(31; "Shipping Agent Code"; Code[10])
        {
            CaptionML = ENU = 'Shipping Agent Code', DEU = 'Zustellercode';
        }
        field(32; "Place of Export"; Code[20])
        {
            CaptionML = ENU = 'Place of Export', DEU = 'Transitstelle';
        }
        field(33; "Invoice Disc. Code"; Code[20])
        {
            CaptionML = ENU = 'Invoice Disc. Code', DEU = 'Rechnungsrabattcode';
        }
        field(34; "Customer Disc. Group"; Code[10])
        {
            CaptionML = ENU = 'Customer Disc. Group', DEU = 'Debitorenrabattgruppe';
        }
        field(35; "Country/Region Code"; Code[10])
        {
            CaptionML = ENU = 'Country/Region Code', DEU = 'Länder-/Regionscode';
        }
        field(36; "Collection Method"; Code[20])
        {
            CaptionML = ENU = 'Collection Method', DEU = 'Einzugsverfahren';
        }
        field(37; "Amount"; Decimal)
        {
            CaptionML = ENU = 'Amount', DEU = 'Betrag';
        }
        field(39; "Blocked"; Option)
        {
            CaptionML = ENU = 'Blocked', DEU = 'Gesperrt';
            OptionMembers = " ",Ship,Invoice,All;
            OptionCaptionML = ENU = ' ,Ship,Invoice,All', DEU = ' ,Liefern,Fakturieren,Alle';
        }
        field(40; "Invoice Copies"; Integer)
        {
            CaptionML = ENU = 'Invoice Copies', DEU = 'Anzahl Rechnungskopien';
        }
        field(41; "Last Statement No."; Integer)
        {
            CaptionML = ENU = 'Last Statement No.', DEU = 'Letzte Kontoauszugsnr.';
        }
        field(42; "Print Statements"; Boolean)
        {
            CaptionML = ENU = 'Print Statements', DEU = 'Kontoauszüge drucken';
        }
        field(45; "Bill-to Customer No."; Code[20])
        {
            CaptionML = ENU = 'Bill-to Customer No.', DEU = 'Rech. an Deb.-Nr.';
        }
        field(46; "Priority"; Integer)
        {
            CaptionML = ENU = 'Priority', DEU = 'Priorität';
        }
        field(47; "Payment Method Code"; Code[10])
        {
            CaptionML = ENU = 'Payment Method Code', DEU = 'Zahlungsformcode';
        }
        field(54; "Last Date Modified"; Date)
        {
            CaptionML = ENU = 'Last Date Modified', DEU = 'Korrigiert am';
        }
        field(80; "Application Method"; Option)
        {
            CaptionML = ENU = 'Application Method', DEU = 'Ausgleichsmethode';
            OptionMembers = Manual,"Apply to Oldest";
            OptionCaptionML = ENU = 'Manual,Apply to Oldest', DEU = 'Offener Posten,Saldomethode';
        }
        field(82; "Prices Including VAT"; Boolean)
        {
            CaptionML = ENU = 'Prices Including VAT', DEU = 'Preise inkl. MwSt.';
        }
        field(83; "Location Code"; Code[10])
        {
            CaptionML = ENU = 'Location Code', DEU = 'Lagerortcode';
        }
        field(84; "Fax No."; Text[30])
        {
            CaptionML = ENU = 'Fax No.', DEU = 'Faxnr.';
        }
        field(85; "Telex Answer Back"; Text[20])
        {
            CaptionML = ENU = 'Telex Answer Back', DEU = 'Telex Namengeber';
        }
        field(86; "VAT Registration No."; Text[20])
        {
            CaptionML = ENU = 'VAT Registration No.', DEU = 'USt-IdNr.';
        }
        field(87; "Combine Shipments"; Boolean)
        {
            CaptionML = ENU = 'Combine Shipments', DEU = 'Sammelrechnung';
        }
        field(88; "Gen. Bus. Posting Group"; Code[10])
        {
            CaptionML = ENU = 'Gen. Bus. Posting Group', DEU = 'Geschäftsbuchungsgruppe';
        }
        field(91; "Post Code"; Code[20])
        {
            CaptionML = ENU = 'Post Code', DEU = 'PLZ-Code';
        }
        field(92; "County"; Text[30])
        {
            CaptionML = ENU = 'County', DEU = 'Bundesregion';
        }
        field(102; "E-Mail"; Text[80])
        {
            CaptionML = ENU = 'E-Mail', DEU = 'E-Mail';
        }
        field(103; "Home Page"; Text[80])
        {
            CaptionML = ENU = 'Home Page', DEU = 'Homepage';
        }
        field(104; "Reminder Terms Code"; Code[10])
        {
            CaptionML = ENU = 'Reminder Terms Code', DEU = 'Mahnmethodencode';
        }
        field(107; "No. Series"; Code[10])
        {
            CaptionML = ENU = 'No. Series', DEU = 'Nummernserie';
        }
        field(108; "Tax Area Code"; Code[20])
        {
            CaptionML = ENU = 'Tax Area Code', DEU = 'Steuergebietscode';
        }
        field(109; "Tax Liable"; Boolean)
        {
            CaptionML = ENU = 'Tax Liable', DEU = 'Steuerpflichtig';
        }
        field(110; "VAT Bus. Posting Group"; Code[10])
        {
            CaptionML = ENU = 'VAT Bus. Posting Group', DEU = 'MwSt.-Geschäftsbuchungsgruppe';
        }
        field(115; "Reserve"; Option)
        {
            CaptionML = ENU = 'Reserve', DEU = 'Reservieren';
            OptionMembers = Never,Optional,Always;
            OptionCaptionML = ENU = 'Never,Optional,Always', DEU = 'Nie,Optional,Immer';
        }
        field(116; "Block Payment Tolerance"; Boolean)
        {
            CaptionML = ENU = 'Block Payment Tolerance', DEU = 'Zahlungstoleranz sperren';
        }
        field(119; "IC Partner Code"; Code[20])
        {
            CaptionML = ENU = 'IC Partner Code', DEU = 'IC-Partnercode';
        }
        field(124; "Prepayment %"; Decimal)
        {
            CaptionML = ENU = 'Prepayment %', DEU = 'Vorauszahlung %';
        }
        field(5049; "Primary Contact No."; Code[20])
        {
            CaptionML = ENU = 'Primary Contact No.', DEU = 'Primäre Kontaktnr.';
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            CaptionML = ENU = 'Responsibility Center', DEU = 'Zuständigkeitseinheitencode';
        }
        field(5750; "Shipping Advice"; Option)
        {
            CaptionML = ENU = 'Shipping Advice', DEU = 'Versandanweisung';
            OptionMembers = Partial,Complete;
            OptionCaptionML = ENU = 'Partial,Complete', DEU = 'Teillieferung,Komplettlieferung';
        }
        field(5790; "Shipping Time"; DateFormula)
        {
            CaptionML = ENU = 'Shipping Time', DEU = 'Transportzeit';
        }
        field(5792; "Shipping Agent Service Code"; Code[10])
        {
            CaptionML = ENU = 'Shipping Agent Service Code', DEU = 'Zustellertransportartencode';
        }
        field(5900; "Service Zone Code"; Code[10])
        {
            CaptionML = ENU = 'Service Zone Code', DEU = 'Servicegebietscode';
        }
        field(7001; "Allow Line Disc."; Boolean)
        {
            CaptionML = ENU = 'Allow Line Disc.', DEU = 'Zeilenrabatt zulassen';
        }
        field(7600; "Base Calendar Code"; Code[10])
        {
            CaptionML = ENU = 'Base Calendar Code', DEU = 'Basiskalendercode';
        }
        field(7601; "Copy Sell-to Addr. to Qte From"; Option)
        {
            CaptionML = ENU = 'Copy Sell-to Addr. to Qte From', DEU = 'Verk. an Adr. in Ang. v. kop.';
            OptionMembers = Company,Person;
            OptionCaptionML = ENU = 'Company,Person', DEU = 'Unternehmen,Person';
        }
        field(50001; "Commission Category"; Code[20])
        {
            CaptionML = ENU = 'Commission Category', DEU = 'Provisiongruppe';
        }
        field(50002; "Agent Code"; Code[10])
        {
            CaptionML = ENU = 'Agent Code', DEU = 'Vertretercode';
        }
        field(50003; "TextCode"; Code[10])
        {
            CaptionML = ENU = 'TextCode', DEU = 'Textbaustein';
        }
        field(50004; "Syndicate"; Boolean)
        {
            CaptionML = ENU = 'Syndicate', DEU = 'Verband';
        }
        field(50005; "Is Member Of"; Code[20])
        {
            CaptionML = ENU = 'Is Member Of', DEU = 'Gehört zu';
        }
        field(50006; "Bonus qualified"; Boolean)
        {
            CaptionML = ENU = 'Bonus qualified', DEU = 'Bonusfähig';
        }
        field(50009; "Tax Code"; Code[20])
        {
            CaptionML = ENU = 'Tax Code', DEU = 'Steuernummer';
        }
        field(50010; "PrintSalesDiscount"; Boolean)
        {
            CaptionML = ENU = 'PrintSalesDiscount', DEU = 'PrintSalesDiscount';
        }
        field(50013; "Central Payer"; Code[20])
        {
            CaptionML = ENU = 'Central Payer', DEU = 'Zentralregulierer';
        }
        field(50014; "Billing Address"; Option)
        {
            CaptionML = ENU = 'Billing Address', DEU = 'Rechnungsadresse';
            OptionMembers = "Bill to Customer","Sell to Customer","Central Payer","Is Member Of";
            OptionCaptionML = ENU = 'Bill to Customer,Sell to Customer,Central Payer,Is Member Of', DEU = 'Rech. an Debitor,Verk. an Debitor,Zentralregulierer,Gehört zu';
        }
        field(50015; "Blocked for Order"; Boolean)
        {
            CaptionML = ENU = 'Blocked for Order', DEU = 'Gesperrt für Auftrag';
        }
        field(50018; "Customer Item No. As"; Code[20])
        {
            CaptionML = ENU = 'Customer Item No. As', DEU = 'Kunden-Artikel-Nr. wie';
        }
        field(50019; "Valuta Date Calculation"; DateFormula)
        {
            CaptionML = ENU = 'Valuta Date Calculation', DEU = 'Valutaformel';
        }
        field(50070; "Private Customer"; Boolean)
        {
            CaptionML = ENU = 'Private Customer', DEU = 'Privatkunde';
        }
        field(50075; "Name 3"; Text[50])
        {
            CaptionML = ENU = 'Name 3', DEU = 'Name 3';
        }
        field(50076; "Branch No."; Code[10])
        {
            CaptionML = ENU = 'Branch No.', DEU = 'Branche';
        }
        field(50077; "Section No."; Code[10])
        {
            CaptionML = ENU = 'Section No.', DEU = 'Sparte';
        }
        field(50078; "External Service"; Code[10])
        {
            CaptionML = ENU = 'External Service', DEU = 'Außendienst';
        }
        field(50079; "ILN-No."; Code[13])
        {
            CaptionML = ENU = 'ILN-No.', DEU = 'ILN-Nummer';
        }
        field(50080; "Syndicate No"; Code[20])
        {
            CaptionML = ENU = 'Syndicate No', DEU = 'Verbandnr';
        }
        field(50081; "Group of Companies"; Code[20])
        {
            CaptionML = ENU = 'Group of Companies', DEU = 'Firmengruppe';
        }
        field(50082; "Union of Companies"; Code[20])
        {
            CaptionML = ENU = 'Union of Companies', DEU = 'Firmenzusammenschluss';
        }
        field(50083; "Group of Firms"; Code[20])
        {
            CaptionML = ENU = 'Group of Firms', DEU = 'Unternehmensgruppe';
        }
        field(50084; "Packing Instruction"; Code[10])
        {
            CaptionML = ENU = 'Packing Instruction', DEU = 'Packvorschrift';
        }
        field(50086; "Text Invoice Collection"; Text[80])
        {
            CaptionML = ENU = 'Text Invoice Collection', DEU = 'Text Rechnungssammler';
        }
        field(50087; "Price in Shipment"; Boolean)
        {
            CaptionML = ENU = 'Price in Shipment', DEU = 'Preise auf Lieferschein';
        }
        field(50088; "Suppress Payment Terms"; Boolean)
        {
            CaptionML = ENU = 'Suppress Payment Terms', DEU = 'Zlg.-Bedingungen nicht drucken';
        }
        field(50091; "Concern"; Code[20])
        {
            CaptionML = ENU = 'Concern', DEU = 'Konzern';
        }
        field(50092; "Regional Group"; Code[20])
        {
            CaptionML = ENU = 'Regional Group', DEU = 'Regionalgruppe';
        }
        field(50094; "Filialnumber"; Code[10])
        {
            CaptionML = ENU = 'Filialnumber', DEU = 'Filialnummer';
        }
        field(50095; "Selective"; Boolean)
        {
            CaptionML = ENU = 'Selective', DEU = 'Selektiv';
        }
        field(50096; "Invoice Output"; Option)
        {
            CaptionML = ENU = 'Invoice Output', DEU = 'Rechnungsausgabe';
            OptionMembers = "None Invoice","Invoice by E-mail","Invoice by Mail";
            OptionCaptionML = ENU = 'None Invoice,Invoice by E-mail,Invoice by Mail', DEU = 'keine Rechnung,Rechnung per Mail,Rechnung per Post';
        }
        field(50097; "Invoice by E-Mail To"; Text[250])
        {
            CaptionML = ENU = 'Invoice by E-Mail To', DEU = 'Rechnung per Mail an';
        }
        field(60002; "eigener Saldo"; Decimal)
        {
            CaptionML = ENU = 'eigener Saldo', DEU = 'Eigener Saldo';
        }
        field(87000; "EdiGLN"; Code[35])
        {
            CaptionML = ENU = 'EdiGLN', DEU = 'GLN (ILN)';
        }
        field(87001; "Billinggroup"; Code[20])
        {
            CaptionML = ENU = 'Billinggroup', DEU = 'Rechnungsgruppe';
        }
        field(87002; "Remote Account No."; Code[20])
        {
            CaptionML = ENU = 'Remote Account No.', DEU = 'Remote Konto Nr.';
        }
        field(87003; "Notification Group"; Code[20])
        {
            CaptionML = ENU = 'Notification Group', DEU = 'Benachricht. Gruppe';
        }
        field(87004; "Partnergroup"; Code[20])
        {
            CaptionML = ENU = 'Partnergroup', DEU = 'Partnergruppe';
        }
        field(87005; "Subst. Partner GLN"; Code[35])
        {
            CaptionML = ENU = 'Subst. Partner GLN', DEU = 'Ersatz Partner GLN';
        }
        field(87006; "Profile Extension"; Text[20])
        {
            CaptionML = ENU = 'Profile Extension', DEU = 'Profil Zusatz';
        }
        field(87007; "Paymentgroup"; Code[20])
        {
            CaptionML = ENU = 'Paymentgroup', DEU = 'Zahlergruppe';
        }
        field(87008; "Cons. Branch No."; Code[20])
        {
            CaptionML = ENU = 'Cons. Branch No.', DEU = 'Warenempf. Filialnr.';
        }
        field(87009; "Bill-to GLN"; Code[35])
        {
            CaptionML = ENU = 'Bill-to GLN', DEU = 'Rech. an GLN';
        }
        field(87010; "Ship-to GLN"; Code[35])
        {
            CaptionML = ENU = 'Ship-to GLN', DEU = 'Lief. an GLN';
        }
        field(87011; "Bilateral ID"; Code[35])
        {
            CaptionML = ENU = 'Bilateral ID', DEU = 'Bilaterale ID';
        }
        field(87050; "Thrd Party Type"; Option)
        {
            CaptionML = ENU = 'Thrd Party Type', DEU = 'Streckenkundentyp';
            OptionMembers = No,"with GLN","without GLN";
            OptionCaptionML = ENU = 'No,with GLN,without GLN', DEU = 'Nein,mit GLN,ohne GLN';
        }
        field(87500; "Plant No."; Code[10])
        {
            CaptionML = ENU = 'Plant No.', DEU = 'Werks Nr.';
        }
        field(87501; "Discharge Location"; Code[10])
        {
            CaptionML = ENU = 'Discharge Location', DEU = 'Abladestelle';
        }
        field(87502; "Stock Location"; Code[25])
        {
            CaptionML = ENU = 'Stock Location', DEU = 'Lagerort';
        }
        field(5001900; "No. Entries for Avis"; Integer)
        {
            CaptionML = ENU = 'No. Entries for Avis', DEU = 'Anz. Posten für Begleitbrief';
        }
        field(5055250; "Liq. Payment Terms Code"; Code[10])
        {
            CaptionML = ENU = 'Liq. Payment Terms Code', DEU = 'Liq. Zlg.-Bedingungscode';
        }
        field(5157802; "Skip Bank Acc. in Bank Import"; Boolean)
        {
            CaptionML = ENU = 'Skip Bank Acc. in Bank Import', DEU = 'Bankkonto beim Bankimport überlesen';
        }
        field(5157803; "Disable Auto Application"; Boolean)
        {
            CaptionML = ENU = 'Disable Auto Application', DEU = 'Autom. Ausgleich unterdrücken';
        }
        field(5157841; "Association No."; Code[20])
        {
            CaptionML = ENU = 'Association No.', DEU = 'Verbandsnr.';
        }
        field(5157842; "Association Sort Code"; Code[20])
        {
            CaptionML = ENU = 'Association Sort Code', DEU = 'Verbandsschlüssel';
        }
        field(5157862; "SearchCity"; Code[30])
        {
            CaptionML = ENU = 'SearchCity', DEU = 'SuchOrt';
        }
        field(5157863; "Balance Acknowledgement Code"; Code[10])
        {
            CaptionML = ENU = 'Balance Acknowledgement Code', DEU = 'Saldobestätigungscode';
        }
        field(5157892; "Preferred Bank Account"; Code[10])
        {
            CaptionML = ENU = 'Preferred Bank Account', DEU = 'Standardbank';
        }
        field(5157893; "Min. Pos. Payment Note"; Integer)
        {
            CaptionML = ENU = 'Min. Pos. Payment Note', DEU = 'Avis ab Posten';
        }
        field(5157894; "Default Charges"; Option)
        {
            CaptionML = ENU = 'Default Charges', DEU = 'Std.-Entgeltregelung';
            OptionMembers = " ",Share,Orderer,Beneficiary;
            OptionCaptionML = ENU = ' ,Share,Orderer,Beneficiary', DEU = ' ,Gebührenteilung,Auftraggeber,Begünstigter';
        }
        field(5157895; "Limit Lines per Head"; Integer)
        {
            CaptionML = ENU = 'Limit Lines per Head', DEU = 'Neuer Kopf ab Zeile';
        }
        field(5374107; "Send-to Email"; Text[80])
        {
            CaptionML = ENU = 'Send-to Email', DEU = 'Senden an Email';
        }
        field(5374108; "Send-to Fax"; Text[30])
        {
            CaptionML = ENU = 'Send-to Fax', DEU = 'Senden an Fax';
        }
        field(5374130; "Reservation Strategy"; Option)
        {
            CaptionML = ENU = 'Reservation Strategy', DEU = 'Reservierungsstrategie';
            OptionMembers = " ","Partially Reservation (Order)","Partially Reservation (Position)","Full Reservation only";
            OptionCaptionML = ENU = ' ,Partially Reservation (Order),Partially Reservation (Position),Full Reservation only', DEU = ' ,Teilreservierung (Auftrag),Teilreservierung (Position),Nur Komplettreservierung';
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

