table 50003 "DMTField"
{
    DataClassification = SystemMetadata;
    fields
    {
        field(20; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', comment = 'Ziel Tabellen ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(21; "Target Field No."; Integer)
        {
            Caption = 'Target Field No.', comment = 'Ziel Feldnr.';
            DataClassification = SystemMetadata;
            TableRelation = Field."No." WHERE(TableNo = field("Target Table ID"));
        }
        field(22; "Target Field Caption"; Text[80])
        {
            Caption = 'Target Field Caption', comment = 'Zielfeld Bezeichnung';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Target Table ID"), "No." = field("Target Field No.")));
        }
        field(23; "Target Field Type"; Text[30])
        {
            Caption = 'Target Field Type', comment = 'Zielfeld Typ';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Type Name" where(TableNo = field("Target Table ID"), "No." = field("Target Field No.")));
        }
        field(24; "Source Table ID"; Integer)
        {
            Caption = 'Source Table ID', comment = 'Herkunft Tabellen ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(31; "Source Field No."; Integer)
        {
            Caption = 'Source Field No.', comment = 'Herkunftsfeld Nr.';
            DataClassification = SystemMetadata;
            TableRelation = DMTFieldBuffer."No." where("To Table No. Filter" = field("Target Table ID"));
            ValidateTableRelation = false;
            BlankZero = true;
            trigger OnValidate()
            begin
                if CurrFieldNo = Rec.FieldNo("Source Field No.") then
                    UpdateSourceFieldCaption();
                UpdateProcessingAction(Rec.FieldNo("Source Field No."));
            end;
        }
        field(33; "Source Field Caption"; Text[80])
        {
            Caption = 'Source Field Caption', comment = 'Herkunftsfeld Bezeichnung';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Source Table ID"), "No." = field("Source Field No.")));
            TableRelation = Field."No." WHERE(TableNo = field("Source Table ID"));
        }
        field(34; "Source Field Type"; Text[30])
        {
            Caption = 'Source Field Type', comment = 'Herkunftsfeld Typ';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Type Name" where(TableNo = field("Source Table ID"), "No." = field("Source Field No.")));
            TableRelation = Field."No." WHERE(TableNo = field("Source Table ID"));
        }

        field(35; "Fixed Value"; Text[250])
        {
            Caption = 'Fixed Value', comment = 'Fester Wert';
            trigger OnValidate()
            var
                ConfigValidateMgt: Codeunit "Config. Validate Management";
                RecRef: RecordRef;
                FldRef: FieldRef;
                ErrorMsg: Text;
            begin
                Rec.TestField("Target Table ID");
                Rec.TestField("Target Field No.");
                if "Fixed Value" <> '' then begin
                    RecRef.Open(Rec."Target Table ID");
                    FldRef := RecRef.Field(Rec."Target Field No.");
                    ErrorMsg := ConfigValidateMgt.EvaluateValue(FldRef, "Fixed Value", false);
                    if ErrorMsg <> '' then
                        Error(ErrorMsg);
                end;
                UpdateProcessingAction(Rec.FieldNo("Fixed Value"));
            end;
        }
        field(50; "Validate Value"; Boolean)
        {
            Caption = 'Validate', comment = 'Validieren';
            InitValue = true;
        }
        field(51; "Use Try Function"; Boolean)
        {
            Caption = 'Use Try Function', comment = 'Try Function verwenden';
            InitValue = true;
        }
        field(52; "Ignore Validation Error"; Boolean)
        {
            Caption = 'Ignore Errors', comment = 'Fehler ignorieren ';
        }
        field(100; "Processing Action"; Option)
        {
            Caption = 'Action', comment = 'Aktion';
            OptionMembers = Ignore,Transfer,FixedValue;
            OptionCaption = 'Ignore,Transfer,Fixed Value', comment = 'Ignorieren,Übertragen,Fester Wert';
        }
        field(101; "Replacements Code"; Code[50])
        {
            Caption = 'Replacements Code', comment = 'Ersetzungen Code';
            TableRelation = DMTReplacementsHeader.Code;
        }
        field(102; "Validation Order"; Integer)
        {
            Caption = 'Validation Order', comment = 'Reihenfolge Validierung';
        }
        field(103; BufferTableTypeFilter; Enum BufferTableType)
        {
            Caption = 'Buffer Table Type Filter', comment = 'Puffertabellenart Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; "Target Table ID", "Target Field No.") { Clustered = true; }
        key(ValidationOrder; "Validation Order") { }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Target Table ID", "Source Field Caption", "Target Field Caption") { }
    }
    internal procedure FilterBy(DMTTable: Record DMTTable) NotIsEmpty: Boolean
    begin
        Rec.SetRange("Target Table ID", DMTTable."Target Table ID");
        NotIsEmpty := not Rec.IsEmpty;
    end;

    internal procedure InitForTargetTable(DMTTable: Record DMTTable): Boolean
    var
        DMTFields: Record "DMTField";
        DMTFields_NEW: Record "DMTField";
        TargetRecRef: RecordRef;
        i: Integer;
    begin
        if DMTTable."Target Table ID" = 0 then
            exit(false);
        TargetRecRef.Open(DMTTable."Target Table ID");
        for i := 1 to TargetRecRef.FieldCount do begin
            if TargetRecRef.FieldIndex(i).Active then
                if (TargetRecRef.FieldIndex(i).Class = TargetRecRef.FieldIndex(i).Class::Normal) then begin
                    DMTFields.FilterBy(DMTTable);
                    DMTFields.setrange("Target Field No.", TargetRecRef.FieldIndex(i).Number);
                    if DMTFields.IsEmpty then begin
                        DMTFields_NEW."Source Table ID" := DMTTable."Buffer Table ID";
                        DMTFields_NEW."Target Field No." := TargetRecRef.FieldIndex(i).Number;
                        DMTFields_NEW."Target Table ID" := DMTTable."Target Table ID";
                        DMTFields_NEW."Processing Action" := DMTFields_NEW."Processing Action"::Ignore; //default for fields without action
                        DMTFields_NEW."Validation Order" := i * 10000;
                        DMTFields_NEW.Insert(true);
                    end;
                end;
        end;
    end;

    internal procedure ProposeMatchingTargetFields(DMTTable: Record DMTTable): Boolean
    var
        DMTFields: Record "DMTField";
        DMTFields2: Record "DMTField";
        GenBuffTable: Record DMTGenBuffTable;
        SourceField: Record Field;
        TargetField: Record Field;
        Found: Boolean;
        BuffTableCaptions: Dictionary of [Integer, Text];
        FoundAtIndex: Integer;
        OldFieldName: text;
        ReplaceExistingMatchesQst: Label 'All fields are already assigned. Overwrite existing assignment?', comment = 'Alle Felder sind bereits zugewiesen. Bestehende Zuordnung überschreiben?';
    begin
        if (DMTTable.BufferTableType = DMTTable.BufferTableType::"Seperate Buffer Table per CSV") then begin
            DMTTable.TestField("Buffer Table ID");
            if not DMTTable.CustomBufferTableExits() then begin
                Message('Keine Puffertabelle mit der ID %1 vorhanden', DMTTable."Buffer Table ID");
                exit;
            end;
            DMTFields.FilterBy(DMTTable);
            DMTFields.SetRange("Source Field No.", 0);

            // Optional Overwrite
            DMTFields2.FilterBy(DMTTable);
            DMTFields2.SetFilter("Source Field No.", '<>%1', 0);
            if DMTFields2.FindFirst() then
                if Confirm(ReplaceExistingMatchesQst) then begin
                    DMTFields.SetRange("Source Field No.");
                end;
            Clear(DMTFields2);
            if DMTFields.FindSet(false, false) then
                repeat
                    TargetField.Get(DMTFields."Target Table ID", DMTFields."Target Field No.");
                    SourceField.SetRange(TableNo, DMTTable."Buffer Table ID");
                    SourceField.SetRange(Enabled, true);
                    SourceField.SetRange(Class, SourceField.Class::Normal);
                    SourceField.SetRange(FieldName, TargetField.FieldName);
                    Found := SourceField.FindFirst();
                    if not Found then
                        if FindFieldNameInOldVersion(TargetField, DMTFields."Target Table ID", OldFieldName) then begin
                            SourceField.SetRange(FieldName, OldFieldName);
                            Found := SourceField.FindFirst();
                        end;
                    if Found then begin
                        DMTFields2 := DMTFields;
                        DMTFields2.Validate("Source Field No.", SourceField."No.");
                        DMTFields2.Modify();
                    end;
                until DMTFields.Next() = 0;
        end;

        if (DMTTable.BufferTableType = DMTTable.BufferTableType::"Generic Buffer Table for all Files") then begin
            GenBuffTable.GetColCaptionForImportedFile(DMTTable, BuffTableCaptions);
            // Loop Target Fields
            DMTFields.FilterBy(DMTTable);
            DMTFields.setrange("Source Field No.", 0);
            if DMTFields.FindSet(true, false) then
                repeat
                    TargetField.Get(DMTFields."Target Table ID", DMTFields."Target Field No.");
                    // 1.Try - Match by Name
                    FoundAtIndex := BuffTableCaptions.Values.IndexOf(TargetField."Field Caption");
                    if FoundAtIndex = 0 then begin
                        if DMTTable."Target Table ID" = Database::"Payment Terms" then
                            case TargetField."Field Caption" of
                                //'Rabatt in %' -> 'Skonto %'
                                'Skonto %':
                                    FoundAtIndex := BuffTableCaptions.Values.IndexOf('Rabatt in %');
                            end;
                    end;
                    // 2.Try - Match by known Name Changes
                    if FoundAtIndex = 0 then
                        if FindFieldNameInOldVersion(TargetField, DMTFields."Target Table ID", OldFieldName) then
                            FoundAtIndex := BuffTableCaptions.Values.IndexOf(OldFieldName);
                    if FoundAtIndex <> 0 then begin
                        DMTFields2 := DMTFields;
                        // Buffer Fields Start from 1000
                        DMTFields2.Validate("Source Field No.", 1000 + BuffTableCaptions.Keys.Get(FoundAtIndex));
                        //DMTFields2."Source Field Caption" := CopyStr(BuffTableCaptions.Get(FoundAtIndex), 1, MaxStrLen(DMTFields2."Source Field Caption"));
                        DMTFields2.UpdateSourceFieldCaption();
                        DMTFields2.Modify();
                    end;
                until DMTFields.Next() = 0;
        end;
    end;

    internal procedure ProposeValidationRules(DMTTable: Record DMTTable): Boolean
    var
        TargetField: Record Field;
        DMTFields: Record "DMTField";
        DMTFields2: Record "DMTField";
        ProdBOMHeader: Record "Production BOM Header";
        RoutingHeader: Record "Routing Header";
        FixedAsset: Record "Fixed Asset";
    // Vendor: Record Vendor;
    // Customer: Record Customer;
    // Contact: Record Contact;
    // GLAccount: Record "G/L Account";
    // CustomerPostingGroup: Record "Customer Posting Group";
    begin
        DMTFields.FilterBy(DMTTable);
        DMTFields.SetRange("Processing Action", DMTFields."Processing Action"::Transfer);
        if DMTFields.FindSet(false, false) then
            repeat
                TargetField.Get(DMTFields."Target Table ID", DMTFields."Target Field No.");
                DMTFields2 := DMTFields;
                case true of
                    TargetField.FieldName IN ['Global Dimension 1 Code',
                                              'Global Dimension 2 Code',
                                              'VAT Registration No.']:
                        begin
                            DMTFields2."Use Try Function" := false;
                        end;
                    (TargetField.TableNo = Database::Item) and
                    (TargetField.FieldName IN ['Costing Method',
                                               'Tariff No.',
                                               'Base Unit of Measure',
                                               'Indirect Cost %']):
                        begin
                            DMTFields2."Use Try Function" := false;
                        end;
                    (TargetField.TableNo IN [Database::Customer, Database::Vendor]) and
                    (TargetField.FieldName IN ['Primary Contact No.',
                                               'Contact']):
                        begin
                            DMTFields2."Validate Value" := false;
                        end;
                    (TargetField.TableNo IN [Database::Vendor]) and
                    (TargetField.FieldName IN ['Prices Including VAT']):
                        begin
                            DMTFields2."Validate Value" := false;
                        end;
                    (TargetField.TableNo IN [Database::Customer]) and
                    (TargetField.FieldName IN ['Block Payment Tolerance', 'VAT Registration No.']):
                        begin
                            DMTFields2."Validate Value" := false;
                        end;
                    (TargetField.TableNo IN [Database::Contact]) and
                    (TargetField.FieldName IN ['Company No.']):
                        begin
                            DMTFields2."Validate Value" := false;
                        end;
                    (TargetField.FieldName IN ['E-Mail']):
                        begin
                            DMTFields2."Use Try Function" := false;
                        end;
                    (TargetField.TableNo = Database::"Production BOM Header") and
                    (TargetField.FieldName IN ['Status']):
                        begin
                            ProdBOMHeader.Status := ProdBOMHeader.Status::"Under Development";
                            DMTFields2.Validate("Fixed Value", Format(ProdBOMHeader.Status));
                        end;
                    (TargetField.TableNo = Database::"Routing Header") and
                    (TargetField.FieldName IN ['Status']):
                        begin
                            RoutingHeader.Status := RoutingHeader.Status::"Under Development";
                            DMTFields2.Validate("Fixed Value", Format(RoutingHeader.Status));
                        end;
                    (TargetField.TableNo = Database::"G/L Account") and
                    (TargetField.FieldName IN ['Totaling']):
                        begin
                            DMTFields2."Validate Value" := false;
                        end;
                    (TargetField.TableNo = Database::"Customer Posting Group") and
                    (TargetField.FieldName.Contains('Account') or TargetField.FieldName.Contains('Acc.')):
                        begin
                            DMTFields2."Use Try Function" := false;
                        end;
                    (TargetField.TableNo = Database::"Vendor Posting Group") and
                    (TargetField.FieldName.Contains('Account') or TargetField.FieldName.Contains('Acc.')):
                        begin
                            DMTFields2."Use Try Function" := false;
                        end;
                    (TargetField.TableNo = Database::"Fixed Asset") and (TargetField.FieldName in ['Budgeted Asset']):
                        begin
                            DMTFields2."Use Try Function" := false;
                        end;
                end;

                if format(DMTFields2) <> Format(DMTFields) then
                    DMTFields2.Modify()
            until DMTFields.Next() = 0;
    end;

    procedure FindFieldNameInOldVersion(TargetField: Record Field; TargetTableNo: Integer; var OldFieldName: Text) Found: Boolean
    begin
        //* Hier Felder eintragen die in neueren Versionen umbenannt wurden, deren Werte aber 1:1 kopiert werden können
        CLEAR(OldFieldName);
        CASE TRUE OF
            (TargetTableNo = DATABASE::Customer) AND (TargetField.FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = DATABASE::Vendor) AND (TargetField.FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = DATABASE::Contact) AND (TargetField.FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = DATABASE::Item) AND (TargetField.FieldName = 'Country/Region of Origin Code'):
                OldFieldName := 'Country of Origin Code';
            (TargetTableNo = DATABASE::Item) AND (TargetField.FieldName = 'Time Bucket'):
                OldFieldName := 'Reorder Cycle';
            // Item Cross Reference -> Item Reference
            (TargetTableNo = DATABASe::"Item Reference") AND (TargetField.FieldName = 'Reference Type'):
                OldFieldName := 'Cross-Reference Type';
            (TargetTableNo = DATABASe::"Item Reference") AND (TargetField.FieldName = 'Reference Type No.'):
                OldFieldName := 'Cross-Reference Type No.';
            (TargetTableNo = DATABASe::"Item Reference") AND (TargetField.FieldName = 'Reference No.'):
                OldFieldName := 'Cross-Reference No.';
        end; // end_CASE
        Found := OldFieldName <> '';
    end;

    internal procedure UpdateProcessingAction(SrcFieldNo: Integer);
    begin
        case SrcFieldNo of
            Rec.FieldNo(rec."Fixed Value"):
                begin
                    if (xRec."Fixed Value" <> Rec."Fixed Value") then begin
                        case true of
                            (Rec."Fixed Value" <> '') and
                            (Rec."Processing Action" in [Rec."Processing Action"::Ignore, Rec."Processing Action"::Transfer]):
                                Rec."Processing Action" := Rec."Processing Action"::FixedValue;
                            (Rec."Fixed Value" = '') and
                            (Rec."Processing Action" = Rec."Processing Action"::FixedValue):
                                Rec."Processing Action" := Rec."Processing Action"::Transfer;
                        end;
                    end;
                end;
            Rec.FieldNo(rec."Source Field No."):
                begin
                    if (xRec."Source Field No." <> Rec."Source Field No.") then begin
                        if Rec."Source Field No." <> 0 then
                            if Rec."Processing Action" = Rec."Processing Action"::Ignore then
                                Rec."Processing Action" := Rec."Processing Action"::Transfer;
                        if Rec."Source Field No." = 0 then
                            if Rec."Processing Action" = Rec."Processing Action"::Transfer then
                                Rec."Processing Action" := Rec."Processing Action"::Ignore;
                    end;
                end;

        end;
    end;

    procedure CopyToTemp(var TempDMTField: Record DMTField temporary)
    var
        DMTField: Record DMTField;
        TempDMTField2: Record DMTField temporary;
    begin
        DMTField.Copy(Rec);
        if DMTField.FindSet(false, false) then
            repeat
                TempDMTField2 := DMTField;
                TempDMTField2.Insert(false);
            until DMTField.Next() = 0;
        TempDMTField.Copy(TempDMTField2, true);
    end;

    procedure UpdateSourceFieldCaption()
    var
        DMTGenBuffTable: Record DMTGenBuffTable;
        DMTTable: Record DMTTable;
        DMTField: Record DMTField;
        SourceField, TargetField : Record Field;
        BuffTableCaptions: Dictionary of [Integer, Text];
        BuffTableCaption: Text;
    begin
        DMTField := Rec;
        if Rec."Source Field No." = 0 then begin
            Rec."Source Field Caption" := '';
            exit;
        end;
        DMTTable.get(Rec."Target Table ID");
        case DMTTable.BufferTableType of
            DMTTable.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    DMTGenBuffTable.GetColCaptionForImportedFile(DMTTable, BuffTableCaptions);
                    if BuffTableCaptions.Get(Rec."Source Field No." - 1000, BuffTableCaption) then begin
                        TargetField.SetRange(TableNo, Rec."Target Table ID");
                        TargetField.SetFilter("Field Caption", ConvertStr(BuffTableCaption, '@()&', '????'));
                        if (TargetField.Count() = 1) then begin
                            Rec."Source Field Caption" := CopyStr(BuffTableCaption, 1, MaxStrLen(Rec."Source Field Caption"));
                        end;
                    end;
                end;
            DMTTable.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    Rec.TestField("Target Table ID");
                    if SourceField.Get(Rec."Source Table ID", Rec."Source Field No.") then
                        Rec."Source Field Caption" := CopyStr(SourceField."Field Caption", 1, MaxStrLen(Rec."Source Field Caption"));
                    ;
                end;
        end;
        if Format(DMTField) <> Format(Rec) then
            Rec.Modify();
    end;
}