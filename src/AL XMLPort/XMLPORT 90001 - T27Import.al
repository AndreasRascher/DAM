xmlport 90001 T27Import
{
    Caption = 'Artikel';
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
            tableelement(Item; T27Buffer)
            {
                XmlName = 'Item';
                fieldelement("No"; Item."No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("No2"; Item."No. 2") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Description"; Item."Description") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SearchDescription"; Item."Search Description") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Description2"; Item."Description 2") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BaseUnitofMeasure"; Item."Base Unit of Measure") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PriceUnitConversion"; Item."Price Unit Conversion") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("InventoryPostingGroup"; Item."Inventory Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ShelfNo"; Item."Shelf No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ItemDiscGroup"; Item."Item Disc. Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AllowInvoiceDisc"; Item."Allow Invoice Disc.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("StatisticsGroup"; Item."Statistics Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CommissionGroup"; Item."Commission Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitPrice"; Item."Unit Price") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PriceProfitCalculation"; Item."Price/Profit Calculation") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Profit"; Item."Profit %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CostingMethod"; Item."Costing Method") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitCost"; Item."Unit Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("StandardCost"; Item."Standard Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LastDirectCost"; Item."Last Direct Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("IndirectCost"; Item."Indirect Cost %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CostisAdjusted"; Item."Cost is Adjusted") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AllowOnlineAdjustment"; Item."Allow Online Adjustment") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VendorNo"; Item."Vendor No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VendorItemNo"; Item."Vendor Item No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LeadTimeCalculation"; Item."Lead Time Calculation") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReorderPoint"; Item."Reorder Point") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("MaximumInventory"; Item."Maximum Inventory") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReorderQuantity"; Item."Reorder Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AlternativeItemNo"; Item."Alternative Item No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitListPrice"; Item."Unit List Price") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DutyDue"; Item."Duty Due %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DutyCode"; Item."Duty Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GrossWeight"; Item."Gross Weight") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NetWeight"; Item."Net Weight") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitsperParcel"; Item."Units per Parcel") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UnitVolume"; Item."Unit Volume") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Durability"; Item."Durability") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FreightType"; Item."Freight Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TariffNo"; Item."Tariff No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DutyUnitConversion"; Item."Duty Unit Conversion") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CountryRegionPurchasedCode"; Item."Country/Region Purchased Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BudgetQuantity"; Item."Budget Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BudgetedAmount"; Item."Budgeted Amount") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BudgetProfit"; Item."Budget Profit") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Blocked"; Item."Blocked") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LastDateModified"; Item."Last Date Modified") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PriceIncludesVAT"; Item."Price Includes VAT") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATBusPostingGrPrice"; Item."VAT Bus. Posting Gr. (Price)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GenProdPostingGroup"; Item."Gen. Prod. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CountryRegionofOriginCode"; Item."Country/Region of Origin Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AutomaticExtTexts"; Item."Automatic Ext. Texts") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NoSeries"; Item."No. Series") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TaxGroupCode"; Item."Tax Group Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VATProdPostingGroup"; Item."VAT Prod. Posting Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Reserve"; Item."Reserve") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GlobalDimension1Code"; Item."Global Dimension 1 Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("GlobalDimension2Code"; Item."Global Dimension 2 Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LowLevelCode"; Item."Low-Level Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LotSize"; Item."Lot Size") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SerialNos"; Item."Serial Nos.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LastUnitCostCalcDate"; Item."Last Unit Cost Calc. Date") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RolledupMaterialCost"; Item."Rolled-up Material Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RolledupCapacityCost"; Item."Rolled-up Capacity Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Scrap"; Item."Scrap %") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("InventoryValueZero"; Item."Inventory Value Zero") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DiscreteOrderQuantity"; Item."Discrete Order Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("MinimumOrderQuantity"; Item."Minimum Order Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("MaximumOrderQuantity"; Item."Maximum Order Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SafetyStockQuantity"; Item."Safety Stock Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OrderMultiple"; Item."Order Multiple") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SafetyLeadTime"; Item."Safety Lead Time") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FlushingMethod"; Item."Flushing Method") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReplenishmentSystem"; Item."Replenishment System") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RoundingPrecision"; Item."Rounding Precision") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SalesUnitofMeasure"; Item."Sales Unit of Measure") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PurchUnitofMeasure"; Item."Purch. Unit of Measure") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReorderCycle"; Item."Reorder Cycle") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ReorderingPolicy"; Item."Reordering Policy") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("IncludeInventory"; Item."Include Inventory") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ManufacturingPolicy"; Item."Manufacturing Policy") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ManufacturerCode"; Item."Manufacturer Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ItemCategoryCode"; Item."Item Category Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CreatedFromNonstockItem"; Item."Created From Nonstock Item") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ProductGroupCode"; Item."Product Group Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ServiceItemGroup"; Item."Service Item Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ItemTrackingCode"; Item."Item Tracking Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LotNos"; Item."Lot Nos.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ExpirationCalculation"; Item."Expiration Calculation") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SpecialEquipmentCode"; Item."Special Equipment Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PutawayTemplateCode"; Item."Put-away Template Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PutawayUnitofMeasureCode"; Item."Put-away Unit of Measure Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PhysInvtCountingPeriodCode"; Item."Phys Invt Counting Period Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("LastCountingPeriodUpdate"; Item."Last Counting Period Update") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NextCountingPeriod"; Item."Next Counting Period") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("UseCrossDocking"; Item."Use Cross-Docking") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CommissionCategory"; Item."Commission Category") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CommissionType"; Item."Commission Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("AllowLineDisc"; Item."Allow Line Disc.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Bonusqualified"; Item."Bonus qualified") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PriceUnitPurchase"; Item."Price Unit Purchase") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PriceUnitSales"; Item."Price Unit Sales") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PriceUnitPurchaseQuantity"; Item."Price Unit Purchase Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PriceUnitSalesQuantity"; Item."Price Unit Sales Quantity") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PriceGroup"; Item."Price Group") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ProductionUnitofMeasure"; Item."Production Unit of Measure") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BlockedforOrder"; Item."Blocked for Order") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("QSCheck"; Item."QS Check") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("PackageYN"; Item."Package (Y/N)") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Tray"; Item."Tray") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Knife"; Item."Knife") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("KnifeSharpener"; Item."Knife Sharpener") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("KnifeCase"; Item."Knife Case") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Sledge"; Item."Sledge") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("VoltHz"; Item."Volt/Hz.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Colour"; Item."Colour") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OldItemNo"; Item."Old Item No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Application1"; Item."Application 1") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Application2"; Item."Application 2") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SpecialEquipment"; Item."Special Equipment") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Electronics"; Item."Electronics") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DrawingNoGraef"; Item."Drawing No. Graef") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SurchargeItem"; Item."Surcharge Item") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("NoCommission"; Item."No Commission") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("BusinessDomain"; Item."Business Domain") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ClassofGoods"; Item."Class of Goods") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ItemClass"; Item."Item Class") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ProductClass"; Item."Product Class") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Longtermsuppliersdecl"; Item."Long term suppliers decl.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Information"; Item."Information") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ItemGTIN"; Item."Item GTIN") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DebCredCode"; Item."Deb-Cred Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ConsumptionUoM"; Item."Consumption UoM") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("DiffGTINType"; Item."Diff. GTIN-Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RoutingNo"; Item."Routing No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("ProductionBOMNo"; Item."Production BOM No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SingleLevelMaterialCost"; Item."Single-Level Material Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SingleLevelCapacityCost"; Item."Single-Level Capacity Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SingleLevelSubcontrdCost"; Item."Single-Level Subcontrd. Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SingleLevelCapOvhdCost"; Item."Single-Level Cap. Ovhd Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SingleLevelMfgOvhdCost"; Item."Single-Level Mfg. Ovhd Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OverheadRate"; Item."Overhead Rate") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RolledupSubcontractedCost"; Item."Rolled-up Subcontracted Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RolledupMfgOvhdCost"; Item."Rolled-up Mfg. Ovhd Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RolledupCapOverheadCost"; Item."Rolled-up Cap. Overhead Cost") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("OrderTrackingPolicy"; Item."Order Tracking Policy") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Critical"; Item."Critical") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("CommonItemNo"; Item."Common Item No.") { FieldValidate = No; MinOccurs = Zero; }
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
            MESSAGE(LinesProcessedMsg, Item.TABLECAPTION, ReceivedLinesCount);
    end;

    trigger OnPreXmlPort()
    begin
        ClearBufferBeforeImportTable(Item.RECORDID.TABLENO);
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
