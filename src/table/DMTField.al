table 110003 "DMTField"
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
            // FieldClass = FlowField;
            Editable = false;
            // CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Source Table ID"), "No." = field("Source Field No.")));
            // TableRelation = Field."No." WHERE(TableNo = field("Source Table ID"));
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
        field(200; Comment; Text[250])
        {
            Caption = 'Comment', Comment = 'Bemerkung';
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

    internal procedure AssignSourceToTargetFields(DMTTable: Record DMTTable)
    var
        DMTField: Record DMTField;
        SourceFieldNames, TargetFieldNames : Dictionary of [Integer, Text];
        FoundAtIndex: Integer;
        SourceFieldID, TargetFieldID : Integer;
        NewFieldName, SourceFieldName : Text;
    begin
        // Load Target Field Names
        TargetFieldNames := CreateTargetFieldNamesDict(DMTTable);
        If TargetFieldNames.Count = 0 then
            exit;

        //Load Source Field Names
        SourceFieldNames := CreateSourceFieldNamesDict(DMTTable);
        If SourceFieldNames.Count = 0 then
            exit;

        //Match Fields by Name
        foreach SourceFieldID in SourceFieldNames.Keys do begin
            SourceFieldName := SourceFieldNames.Get(SourceFieldID);
            FoundAtIndex := TargetFieldNames.Values.IndexOf(SourceFieldName);
            // TargetField.SetFilter(FieldName, ConvertStr(BuffTableCaption, '@()&', '????'));
            if FoundAtIndex = 0 then
                if FindFieldNameInOldVersion(SourceFieldName, DMTTable."Target Table ID", NewFieldName) then
                    FoundAtIndex := TargetFieldNames.Values.IndexOf(NewFieldName);
            if FoundAtIndex <> 0 then begin
                TargetFieldID := TargetFieldNames.Keys.Get(FoundAtIndex);
                // SetSourceField
                DMTField.Get(DMTTable."Target Table ID", TargetFieldID);
                DMTField.Validate("Source Field No.", SourceFieldID); // Validate to update processing action
                DMTField."Source Field Caption" := copyStr(TargetFieldNames.Get(TargetFieldID), 1, MaxStrLen(DMTField."Source Field Caption"));
                DMTField.Modify();
            end;
        end;
    end;

    internal procedure ProposeValidationRules(DMTTable: Record DMTTable): Boolean
    var
        DMTFields: Record "DMTField";
        DMTFields2: Record "DMTField";
        DMTValidationRuleLib: Codeunit DMTValidationRuleLib;
    begin
        DMTFields.FilterBy(DMTTable);
        DMTFields.SetRange("Processing Action", DMTFields."Processing Action"::Transfer);
        if DMTFields.FindSet(true, false) then
            repeat
                DMTFields2 := DMTFields;
                DMTValidationRuleLib.SetKnownValidationRules(DMTFields);
                if format(DMTFields2) <> Format(DMTFields) then
                    DMTFields2.Modify()
            until DMTFields.Next() = 0;
    end;

    procedure FindFieldNameInOldVersion(FieldName: Text; TargetTableNo: Integer; var OldFieldName: Text) Found: Boolean
    begin
        //* Hier Felder eintragen die in neueren Versionen umbenannt wurden, deren Werte aber 1:1 kopiert werden können
        CLEAR(OldFieldName);
        CASE TRUE OF
            (TargetTableNo = DATABASE::Customer) AND (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = DATABASE::Vendor) AND (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = DATABASE::Contact) AND (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = DATABASE::Item) AND (FieldName = 'Country/Region of Origin Code'):
                OldFieldName := 'Country of Origin Code';
            (TargetTableNo = DATABASE::Item) AND (FieldName = 'Time Bucket'):
                OldFieldName := 'Reorder Cycle';
            // Item Cross Reference -> Item Reference
            (TargetTableNo = DATABASe::"Item Reference") AND (FieldName = 'Reference Type'):
                OldFieldName := 'Cross-Reference Type';
            (TargetTableNo = DATABASe::"Item Reference") AND (FieldName = 'Reference Type No.'):
                OldFieldName := 'Cross-Reference Type No.';
            (TargetTableNo = DATABASe::"Item Reference") AND (FieldName = 'Reference No.'):
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

    local procedure CreateSourceFieldNamesDict(DMTTable: Record DMTTable) SourceFieldNames: Dictionary of [Integer, Text]
    var
        GenBuffTable: Record DMTGenBuffTable;
        Field: Record Field;
        SourceFieldNames2: Dictionary of [Integer, Text];
        FieldID: Integer;
    begin
        case DMTTable.BufferTableType of
            DMTTable.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    Field.SetRange(TableNo, DMTTable."Buffer Table ID");
                    Field.SetRange(Enabled, true);
                    Field.SetRange(Class, Field.Class::Normal);
                    Field.FindSet();
                    repeat
                        SourceFieldNames.Add(Field."No.", Field.FieldName);
                    until Field.Next() = 0;
                end;
            DMTTable.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    GenBuffTable.GetColCaptionForImportedFile(DMTTable.GetDataFilePath(), SourceFieldNames2);
                    foreach FieldID in SourceFieldNames2.Keys do begin
                        SourceFieldNames.Add(FieldID + 1000, SourceFieldNames2.Get(FieldID));
                    end;
                end;
        end;
    end;

    local procedure CreateTargetFieldNamesDict(var DMTTable: Record DMTTable) TargetFieldNames: Dictionary of [Integer, Text]
    var
        DMTField: Record DMTField;
        Field: Record Field;
        ReplaceExistingMatchesQst: Label 'All fields are already assigned. Overwrite existing assignment?', comment = 'Alle Felder sind bereits zugewiesen. Bestehende Zuordnung überschreiben?';
    begin
        DMTField.FilterBy(DMTTable);
        DMTField.SetFilter("Source Field No.", '<>%1', 0);
        if DMTField.FindFirst() then begin
            if Confirm(ReplaceExistingMatchesQst) then begin
                DMTField.SetRange("Source Field No.");
            end;
        end else begin
            DMTField.SetRange("Source Field No."); // no fields assigned case
        end;
        if not DMTField.FindSet() then
            exit;
        repeat
            Field.get(DMTField."Target Table ID", DMTField."Target Field No.");
            TargetFieldNames.Add(Field."No.", Field.FieldName);
        until DMTField.Next() = 0;
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
        if Rec."Source Field No." = 0 then begin
            Rec."Source Field Caption" := '';
            exit;
        end;
        DMTField := Rec;
        DMTTable.get(Rec."Target Table ID");
        case DMTTable.BufferTableType of
            DMTTable.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    DMTGenBuffTable.GetColCaptionForImportedFile(DMTTable.GetDataFilePath(), BuffTableCaptions);
                    if BuffTableCaptions.Get(Rec."Source Field No." - 1000, BuffTableCaption) then begin
                        TargetField.SetRange(TableNo, Rec."Target Table ID");
                        TargetField.SetFilter(FieldName, ConvertStr(BuffTableCaption, '@()&', '????'));
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
                end;
        end;
        if Format(DMTField) <> Format(Rec) then
            Rec.Modify();
    end;
}