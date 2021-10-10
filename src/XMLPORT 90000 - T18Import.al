xmlport 90000 T18Import
{
    Caption = 'Debitor';
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
            tableelement(Customer; T18Buffer)
            {
                XmlName = 'Customer';
                fieldelement("No"; Customer."No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Name"; Customer."Name") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SearchName"; Customer."Search Name") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Name2"; Customer."Name 2") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Address"; Customer."Address") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Address2"; Customer."Address 2") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("City"; Customer."City") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Contact"; Customer."Contact") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PhoneNo"; Customer."Phone No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TelexNo"; Customer."Telex No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OurAccountNo"; Customer."Our Account No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TerritoryCode"; Customer."Territory Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GlobalDimension1Code"; Customer."Global Dimension 1 Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GlobalDimension2Code"; Customer."Global Dimension 2 Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ChainName"; Customer."Chain Name") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BudgetedAmount"; Customer."Budgeted Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CreditLimitLCY"; Customer."Credit Limit (LCY)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CustomerPostingGroup"; Customer."Customer Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CurrencyCode"; Customer."Currency Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CustomerPriceGroup"; Customer."Customer Price Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LanguageCode"; Customer."Language Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("StatisticsGroup"; Customer."Statistics Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PaymentTermsCode"; Customer."Payment Terms Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FinChargeTermsCode"; Customer."Fin. Charge Terms Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SalespersonCode"; Customer."Salesperson Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShipmentMethodCode"; Customer."Shipment Method Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippingAgentCode"; Customer."Shipping Agent Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PlaceofExport"; Customer."Place of Export") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("InvoiceDiscCode"; Customer."Invoice Disc. Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CustomerDiscGroup"; Customer."Customer Disc. Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CountryRegionCode"; Customer."Country/Region Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CollectionMethod"; Customer."Collection Method") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Amount"; Customer."Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Blocked"; Customer."Blocked") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("InvoiceCopies"; Customer."Invoice Copies") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LastStatementNo"; Customer."Last Statement No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrintStatements"; Customer."Print Statements") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BilltoCustomerNo"; Customer."Bill-to Customer No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Priority"; Customer."Priority") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PaymentMethodCode"; Customer."Payment Method Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LastDateModified"; Customer."Last Date Modified") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ApplicationMethod"; Customer."Application Method") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PricesIncludingVAT"; Customer."Prices Including VAT") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LocationCode"; Customer."Location Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FaxNo"; Customer."Fax No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TelexAnswerBack"; Customer."Telex Answer Back") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATRegistrationNo"; Customer."VAT Registration No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CombineShipments"; Customer."Combine Shipments") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GenBusPostingGroup"; Customer."Gen. Bus. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PostCode"; Customer."Post Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("County"; Customer."County") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("EMail"; Customer."E-Mail") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("HomePage"; Customer."Home Page") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReminderTermsCode"; Customer."Reminder Terms Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NoSeries"; Customer."No. Series") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TaxAreaCode"; Customer."Tax Area Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TaxLiable"; Customer."Tax Liable") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATBusPostingGroup"; Customer."VAT Bus. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Reserve"; Customer."Reserve") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BlockPaymentTolerance"; Customer."Block Payment Tolerance") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ICPartnerCode"; Customer."IC Partner Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Prepayment"; Customer."Prepayment %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrimaryContactNo"; Customer."Primary Contact No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ResponsibilityCenter"; Customer."Responsibility Center") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippingAdvice"; Customer."Shipping Advice") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippingTime"; Customer."Shipping Time") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShippingAgentServiceCode"; Customer."Shipping Agent Service Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ServiceZoneCode"; Customer."Service Zone Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AllowLineDisc"; Customer."Allow Line Disc.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BaseCalendarCode"; Customer."Base Calendar Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CopySelltoAddrtoQteFrom"; Customer."Copy Sell-to Addr. to Qte From") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CommissionCategory"; Customer."Commission Category") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AgentCode"; Customer."Agent Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TextCode"; Customer."TextCode") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Syndicate"; Customer."Syndicate") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("IsMemberOf"; Customer."Is Member Of") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Bonusqualified"; Customer."Bonus qualified") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TaxCode"; Customer."Tax Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrintSalesDiscount"; Customer."PrintSalesDiscount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CentralPayer"; Customer."Central Payer") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BillingAddress"; Customer."Billing Address") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BlockedforOrder"; Customer."Blocked for Order") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CustomerItemNoAs"; Customer."Customer Item No. As") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ValutaDateCalculation"; Customer."Valuta Date Calculation") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PrivateCustomer"; Customer."Private Customer") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Name3"; Customer."Name 3") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BranchNo"; Customer."Branch No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SectionNo"; Customer."Section No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ExternalService"; Customer."External Service") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ILNNo"; Customer."ILN-No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SyndicateNo"; Customer."Syndicate No") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GroupofCompanies"; Customer."Group of Companies") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnionofCompanies"; Customer."Union of Companies") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GroupofFirms"; Customer."Group of Firms") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PackingInstruction"; Customer."Packing Instruction") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TextInvoiceCollection"; Customer."Text Invoice Collection") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PriceinShipment"; Customer."Price in Shipment") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SuppressPaymentTerms"; Customer."Suppress Payment Terms") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Concern"; Customer."Concern") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RegionalGroup"; Customer."Regional Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Filialnumber"; Customer."Filialnumber") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Selective"; Customer."Selective") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("InvoiceOutput"; Customer."Invoice Output") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("InvoicebyEMailTo"; Customer."Invoice by E-Mail To") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("eigenerSaldo"; Customer."eigener Saldo") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("EdiGLN"; Customer."EdiGLN") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Billinggroup"; Customer."Billinggroup") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RemoteAccountNo"; Customer."Remote Account No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NotificationGroup"; Customer."Notification Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Partnergroup"; Customer."Partnergroup") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SubstPartnerGLN"; Customer."Subst. Partner GLN") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ProfileExtension"; Customer."Profile Extension") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Paymentgroup"; Customer."Paymentgroup") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ConsBranchNo"; Customer."Cons. Branch No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BilltoGLN"; Customer."Bill-to GLN") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShiptoGLN"; Customer."Ship-to GLN") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BilateralID"; Customer."Bilateral ID") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ThrdPartyType"; Customer."Thrd Party Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PlantNo"; Customer."Plant No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DischargeLocation"; Customer."Discharge Location") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("StockLocation"; Customer."Stock Location") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NoEntriesforAvis"; Customer."No. Entries for Avis") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LiqPaymentTermsCode"; Customer."Liq. Payment Terms Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SkipBankAccinBankImport"; Customer."Skip Bank Acc. in Bank Import") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DisableAutoApplication"; Customer."Disable Auto Application") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AssociationNo"; Customer."Association No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AssociationSortCode"; Customer."Association Sort Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SearchCity"; Customer."SearchCity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BalanceAcknowledgementCode"; Customer."Balance Acknowledgement Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PreferredBankAccount"; Customer."Preferred Bank Account") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("MinPosPaymentNote"; Customer."Min. Pos. Payment Note") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DefaultCharges"; Customer."Default Charges") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LimitLinesperHead"; Customer."Limit Lines per Head") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SendtoEmail"; Customer."Send-to Email") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SendtoFax"; Customer."Send-to Fax") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReservationStrategy"; Customer."Reservation Strategy") { FieldValidate = No; MinOccurs = Zero; }
                trigger OnBeforeInsertRecord()
                begin
                    ReceivedLinesCount += 1;

                    //SKIP HEADER LINES
                    IF ReceivedLinesCount <= StartFromLine then
                        currXMLport.SKIP();
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
                    field(DatabaseName; GetDatabaseName()) { Caption = 'Database'; ApplicationArea = all; }
                    field(COMPANYNAME; COMPANYNAME) { Caption = 'Company'; ApplicationArea = all; }
                }
            }
        }
    }

    trigger OnPostXmlPort()
    var
        LinesProcessedMsg: Label '%1 Buffer\%2 lines imported';
    begin
        IF currXMLport.FILENAME <> '' then //only for manual excecution
            MESSAGE(LinesProcessedMsg, Customer.TABLECAPTION, ReceivedLinesCount);
    end;

    trigger OnPreXmlPort()
    begin
        ClearBufferBeforeImportTable(Customer.RECORDID.TABLENO);
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
            BufferRef.DELETEALL();
    end;

    procedure GetDatabaseName(): Text[250]
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SETRANGE("Server Instance ID", SERVICEINSTANCEID());
        ActiveSession.SETRANGE("Session ID", SESSIONID());
        ActiveSession.findfirst();
        exit(ActiveSession."Database Name");
    end;
}

