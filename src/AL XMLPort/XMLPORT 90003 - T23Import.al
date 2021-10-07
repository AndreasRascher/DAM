xmlport 90003 T23Import
{
    Caption = 'Kreditor';
    Direction = Import;
    FieldSeparator = '<TAB>';
    FieldDelimiter = '<None>';
    TextEncoding = UTF16;
    Format = VariableText;
    FormatEvaluate = Xml;

    schema
    {
        textelement(Root)
        {
            tableelement(Vendor; T23Buffer)
            {
                XmlName = 'Vendor';
                fieldelement("No"; Vendor."No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Name"; Vendor."Name") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SearchName"; Vendor."Search Name") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Name2"; Vendor."Name 2") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Address"; Vendor."Address") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Address2"; Vendor."Address 2") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("City"; Vendor."City") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Contact"; Vendor."Contact") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PhoneNo"; Vendor."Phone No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TelexNo"; Vendor."Telex No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OurAccountNo"; Vendor."Our Account No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TerritoryCode"; Vendor."Territory Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GlobalDimension1Code"; Vendor."Global Dimension 1 Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GlobalDimension2Code"; Vendor."Global Dimension 2 Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BudgetedAmount"; Vendor."Budgeted Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VendorPostingGroup"; Vendor."Vendor Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CurrencyCode"; Vendor."Currency Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LanguageCode"; Vendor."Language Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("StatisticsGroup"; Vendor."Statistics Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PaymentTermsCode"; Vendor."Payment Terms Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FinChargeTermsCode"; Vendor."Fin. Charge Terms Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PurchaserCode"; Vendor."Purchaser Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShipmentMethodCode"; Vendor."Shipment Method Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippingAgentCode"; Vendor."Shipping Agent Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("InvoiceDiscCode"; Vendor."Invoice Disc. Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CountryRegionCode"; Vendor."Country/Region Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Blocked"; Vendor."Blocked") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PaytoVendorNo"; Vendor."Pay-to Vendor No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Priority"; Vendor."Priority") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PaymentMethodCode"; Vendor."Payment Method Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LastDateModified"; Vendor."Last Date Modified") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ApplicationMethod"; Vendor."Application Method") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PricesIncludingVAT"; Vendor."Prices Including VAT") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FaxNo"; Vendor."Fax No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TelexAnswerBack"; Vendor."Telex Answer Back") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATRegistrationNo"; Vendor."VAT Registration No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GenBusPostingGroup"; Vendor."Gen. Bus. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PostCode"; Vendor."Post Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("County"; Vendor."County") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("EMail"; Vendor."E-Mail") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("HomePage"; Vendor."Home Page") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NoSeries"; Vendor."No. Series") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TaxAreaCode"; Vendor."Tax Area Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TaxLiable"; Vendor."Tax Liable") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATBusPostingGroup"; Vendor."VAT Bus. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BlockPaymentTolerance"; Vendor."Block Payment Tolerance") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ICPartnerCode"; Vendor."IC Partner Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Prepayment"; Vendor."Prepayment %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrimaryContactNo"; Vendor."Primary Contact No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ResponsibilityCenter"; Vendor."Responsibility Center") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LocationCode"; Vendor."Location Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LeadTimeCalculation"; Vendor."Lead Time Calculation") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BaseCalendarCode"; Vendor."Base Calendar Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RegistrationNo"; Vendor."Registration No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TextCode"; Vendor."TextCode") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("EdiGLN"; Vendor."EdiGLN") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Billinggroup"; Vendor."Billinggroup") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RemoteAccountNo"; Vendor."Remote Account No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NotificationGroup"; Vendor."Notification Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Partnergroup"; Vendor."Partnergroup") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ProfileExtension"; Vendor."Profile Extension") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BilateralID"; Vendor."Bilateral ID") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PlantNo"; Vendor."Plant No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DischargeLocation"; Vendor."Discharge Location") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("StockLocation"; Vendor."Stock Location") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NoEntriesforAvis"; Vendor."No. Entries for Avis") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DirectionCode"; Vendor."Direction Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PaymentType"; Vendor."Payment Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DeliveryReminderTerms"; Vendor."Delivery Reminder Terms") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LiqPaymentTermsCode"; Vendor."Liq. Payment Terms Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SkipBankAccinBankImport"; Vendor."Skip Bank Acc. in Bank Import") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DisableAutoApplication"; Vendor."Disable Auto Application") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AssociationNo"; Vendor."Association No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AssociationSortCode"; Vendor."Association Sort Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SearchCity"; Vendor."SearchCity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BalanceAcknowledgementCode"; Vendor."Balance Acknowledgement Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PreferredBankAccount"; Vendor."Preferred Bank Account") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("MinPosPaymentNote"; Vendor."Min. Pos. Payment Note") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DefaultCharges"; Vendor."Default Charges") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LimitLinesperHead"; Vendor."Limit Lines per Head") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TradingType"; Vendor."Trading Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ServiceNo"; Vendor."Service No.") { FieldValidate = No; MinOccurs = Zero; }
                trigger OnBeforeInsertRecord()
                begin
                    ReceivedLinesCount += 1;

                    //SKIP HEADER LINES
                    IF ReceivedLinesCount <= StartFromLine then begin
                        currXMLport.SKIP();
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Umgebung)
                {
                    Caption = 'Environment';
                    field(GetDatabaseName; GetDatabaseName()) { Caption = 'Database'; }
                    field(COMPANYNAME; COMPANYNAME) { Caption = 'Company'; }
                }
            }
        }
    }

    trigger OnPostXmlPort()
    var
        LinesProcessedMsg: Label '%1 Buffer\%2 lines imported';
    begin
        IF currXMLport.FILENAME <> '' then //only for manual excecution
            MESSAGE(LinesProcessedMsg, Vendor.TABLECAPTION, ReceivedLinesCount);
    end;

    trigger OnPreXmlPort()
    begin
        ClearBufferBeforeImportTable(Vendor.RECORDID.TABLENO);
    end;

    var
        ReceivedLinesCount: Integer;
        StartFromLine: Integer;

    procedure GetFieldCaption(_TableNo: Integer;
    _FieldNo: Integer) _FieldCpt: Text[1024]
    var
        _Field: Record "Field";
    begin
        IF _TableNo = 0 then exit('');
        IF _FieldNo = 0 then exit('');
        IF NOT _Field.GET(_TableNo, _FieldNo) then exit('');
        _FieldCpt := _Field."Field Caption";
    end;

    procedure RemoveSpecialChars(TextIn: Text[1024]) TextOut: Text[1024]
    var
        CharArray: Text[30];
    begin
        CharArray[1] := 9; // TAB
        CharArray[2] := 10; // LF
        CharArray[3] := 13; // CR
        exit(DELCHR(TextIn, '=', CharArray));
    end;

    local procedure ClearBufferBeforeImportTable(BufferTableNo: Integer)
    var
        BufferRef: RecordRef;
    begin
        //* Puffertabelle l”schen vor dem Import
        IF NOT currXMLport.IMPORTFILE then
            exit;
        IF BufferTableNo < 50000 then begin
            MESSAGE('Achtung: Puffertabellen ID kleiner 50000');
            exit;
        end;
        BufferRef.OPEN(BufferTableNo);
        IF NOT BufferRef.ISEMPTY then
            BufferRef.DeleteAll();
    end;

    procedure GetDatabaseName(): Text[250]
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SETRANGE("Server Instance ID", SERVICEINSTANCEID);
        ActiveSession.SETRANGE("Session ID", SESSIONID());
        ActiveSession.findfirst();
        exit(ActiveSession."Database Name");
    end;
}
