table 91002 "DAMField"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(20; "To Table No."; Integer)
        {
            CaptionML = DEU = 'Ziel Tabellen ID', ENU = 'Target Table ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(21; "To Field No."; Integer)
        {
            CaptionML = DEU = 'Ziel Feldnr.', ENU = 'Target Field No.';
            DataClassification = SystemMetadata;
            TableRelation = Field."No." WHERE(TableNo = field("To Table No."));
        }
        field(22; "To Field Caption"; Text[80])
        {
            CaptionML = DEU = 'Zielfeld Bezeichnung', ENU = 'Target Field Caption';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("To Table No."), "No." = field("To Field No.")));
        }
        field(23; "To Field Type"; Text[30])
        {
            CaptionML = DEU = 'Zielfeld Typ', ENU = 'Target Field Type';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Type Name" where(TableNo = field("To Table No."), "No." = field("To Field No.")));
        }
        field(24; "From Table ID"; Integer)
        {
            CaptionML = DEU = 'Herkunft Tabellen ID', ENU = 'Source Table ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(25; "To Field Name"; Text[80])
        {
            CaptionML = DEU = 'Zielfeld Name', ENU = 'Target Field Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field.FieldName where(TableNo = field("To Table No."), "No." = field("To Field No.")));
        }
        field(31; "From Field No."; Integer)
        {
            CaptionML = DEU = 'Herkunft Feldnr.', ENU = 'Source Field No.';
            DataClassification = SystemMetadata;
            TableRelation = Field."No." WHERE(TableNo = field("From Table ID"));
            trigger OnValidate()
            begin
                UpdateProcessingAction(Rec.FieldNo("From Field No."));
            end;
        }
        field(32; "From Field Caption"; Text[80])
        {
            CaptionML = DEU = 'Herkunftsfeld Bezeichnung', ENU = 'Source Field Caption';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("From Table ID"), "No." = field("From Field No.")));
            TableRelation = Field."No." WHERE(TableNo = field("From Table ID"));
        }
        field(33; "From Field Type"; Text[30])
        {
            CaptionML = DEU = 'Herkunftsfeld Typ', ENU = 'Source Field Type';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Type Name" where(TableNo = field("From Table ID"), "No." = field("From Field No.")));
            TableRelation = Field."No." WHERE(TableNo = field("From Table ID"));
        }

        field(34; "Fixed Value"; Text[250])
        {
            CaptionML = DEU = 'Fester Wert', ENU = 'Fixed Value';
            trigger OnValidate()
            var
                ConfigValidateMgt: Codeunit "Config. Validate Management";
                RecRef: RecordRef;
                FldRef: FieldRef;
                ErrorMsg: Text;
            begin
                Rec.TestField("To Table No.");
                Rec.TestField("To Field No.");
                RecRef.Open(Rec."To Table No.");
                FldRef := RecRef.Field(Rec."To Field No.");
                ErrorMsg := ConfigValidateMgt.EvaluateValue(FldRef, "Fixed Value", false);
                if ErrorMsg <> '' then
                    Error(ErrorMsg);
                UpdateProcessingAction(Rec.FieldNo("Fixed Value"));
            end;
        }
        field(50; "Validate Value"; Boolean)
        {
            CaptionML = DEU = 'Validieren', ENU = 'Validate';
            InitValue = true;
        }
        field(51; "Use Try Function"; Boolean)
        {
            CaptionML = DEU = 'Try Function verwenden', ENU = 'Use Try Function';
            InitValue = true;
        }
        field(52; "Ignore Validation Error"; Boolean)
        {
            CaptionML = DEU = 'Fehler ignorieren ', ENU = 'Ignore Errors';
        }
        field(100; "Processing Action"; Option)
        {
            CaptionML = DEU = 'Aktion', ENU = 'Action';
            OptionMembers = Ignore,Transfer,FixedValue;
            OptionCaptionML = DEU = 'Ignorieren,Übertragen,Fester Wert', ENU = 'Ignore,Transfer,Fixed Value';
        }
    }

    keys
    {
        key(PK; "To Table No.", "To Field No.")
        {
            Clustered = true;
        }
    }
    internal procedure FilterBy(DAMTable: Record DAMTable) NotIsEmpty: Boolean
    begin
        Rec.SetRange("To Table No.", DAMTable."To Table ID");
        NotIsEmpty := not Rec.IsEmpty;
    end;

    internal procedure InitForTargetTable(DAMTable: Record DAMTable): Boolean
    var
        DAMFields: Record "DAMField";
        DAMFields_NEW: Record "DAMField";
        TargetRecRef: RecordRef;
        i: Integer;
    begin
        if DAMTable."To Table ID" = 0 then
            exit(false);
        TargetRecRef.Open(DAMTable."To Table ID");
        for i := 1 to TargetRecRef.FieldCount do begin
            if TargetRecRef.FieldIndex(i).Active then
                if (TargetRecRef.FieldIndex(i).Class = TargetRecRef.FieldIndex(i).Class::Normal) then begin
                    DAMFields.FilterBy(DAMTable);
                    DAMFields.setrange("To Field No.", TargetRecRef.FieldIndex(i).Number);
                    if DAMFields.IsEmpty then begin
                        DAMFields_NEW."From Table ID" := DAMTable."Buffer Table ID";
                        DAMFields_NEW."To Field No." := TargetRecRef.FieldIndex(i).Number;
                        DAMFields_NEW."To Table No." := DAMTable."To Table ID";
                        DAMFields_NEW.Insert(true);
                    end;
                end;
        end;
    end;

    internal procedure ProposeMatchingTargetFields(DAMTable: Record DAMTable): Boolean
    var
        SourceField: Record Field;
        TargetField: Record Field;
        DAMFields: Record "DAMField";
        DAMFields2: Record "DAMField";
        OldFieldName: text;
        Found: Boolean;
    begin
        if not DAMTable.BufferTableExits() then begin
            Message('Keine Puffertabelle mit der ID %1 vorhand', DAMTable."Buffer Table ID");
            exit;
        end;
        DAMFields.FilterBy(DAMTable);
        DAMFields.setrange("From Field No.", 0);
        if DAMFields.FindSet(false, false) then
            repeat
                TargetField.Get(DAMFields."To Table No.", DAMFields."To Field No.");
                SourceField.SetRange(TableNo, DAMTable."Buffer Table ID");
                SourceField.SetRange(Enabled, true);
                SourceField.SetRange(Class, SourceField.Class::Normal);
                SourceField.SetRange(FieldName, TargetField.FieldName);
                Found := SourceField.FindFirst();
                if not Found then
                    if FindFieldNameInOldVersion(TargetField, DAMFields."To Table No.", OldFieldName) then begin
                        SourceField.SetRange(FieldName, OldFieldName);
                        Found := SourceField.FindFirst();
                    end;
                if Found then begin
                    DAMFields2 := DAMFields;
                    DAMFields2.Validate("From Field No.", SourceField."No.");
                    DAMFields2.Modify();
                end;
            until DAMFields.Next() = 0;
    end;

    internal procedure ProposeValidationRules(DAMTable: Record DAMTable): Boolean
    var
        TargetField: Record Field;
        DAMFields: Record "DAMField";
        DAMFields2: Record "DAMField";
        ProdBOMHeader: Record "Production BOM Header";
        RoutingHeader: Record "Routing Header";
    // Vendor: Record Vendor;
    // Customer: Record Customer;
    // Contact: Record Contact;
    begin
        DAMFields.FilterBy(DAMTable);
        DAMFields.SetRange("Processing Action", DAMFields."Processing Action"::Transfer);
        if DAMFields.FindSet(false, false) then
            repeat
                TargetField.Get(DAMFields."To Table No.", DAMFields."To Field No.");
                DAMFields2 := DAMFields;
                case true of
                    TargetField.FieldName IN ['Global Dimension 1 Code',
                                              'Global Dimension 2 Code',
                                              'VAT Registration No.']:
                        begin
                            DAMFields2."Use Try Function" := false;
                        end;
                    (TargetField.TableNo = DATabase::Item) and
                    (TargetField.FieldName IN ['Costing Method', 'Tariff No.', 'Base Unit of Measure', 'Indirect Cost %']):
                        begin
                            DAMFields2."Use Try Function" := false;
                        end;
                    (TargetField.TableNo IN [Database::Customer, Database::Vendor]) and
                    (TargetField.FieldName IN ['Primary Contact No.', 'Contact']):
                        begin
                            DAMFields2."Validate Value" := false;
                        end;
                    (TargetField.TableNo IN [Database::Vendor]) and
                    (TargetField.FieldName IN ['Prices Including VAT']):
                        begin
                            DAMFields2."Validate Value" := false;
                        end;
                    (TargetField.TableNo IN [Database::Customer]) and
                    (TargetField.FieldName IN ['Block Payment Tolerance']):
                        begin
                            DAMFields2."Validate Value" := false;
                        end;
                    (TargetField.TableNo IN [Database::Contact]) and
                    (TargetField.FieldName IN ['Company No.']):
                        begin
                            DAMFields2."Validate Value" := false;
                        end;
                    (TargetField.FieldName IN ['E-Mail']):
                        begin
                            DAMFields2."Use Try Function" := false;
                        end;
                    (TargetField.TableNo = DATabase::"Production BOM Header") and
                    (TargetField.FieldName IN ['Status']):
                        begin
                            ProdBOMHeader.Status := ProdBOMHeader.Status::"Under Development";
                            DAMFields2.Validate("Fixed Value", Format(ProdBOMHeader.Status));
                        end;
                    (TargetField.TableNo = DATabase::"Routing Header") and
                    (TargetField.FieldName IN ['Status']):
                        begin
                            RoutingHeader.Status := RoutingHeader.Status::"Under Development";
                            DAMFields2.Validate("Fixed Value", Format(RoutingHeader.Status));
                        end;

                end;

                if format(DAMFields2) <> Format(DAMFields) then
                    DAMFields2.Modify()
            until DAMFields.Next() = 0;
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
            Rec.FieldNo(rec."From Field No."):
                begin
                    if (xRec."From Field No." <> Rec."From Field No.") then begin
                        if Rec."From Field No." <> 0 then
                            if Rec."Processing Action" = Rec."Processing Action"::Ignore then
                                Rec."Processing Action" := Rec."Processing Action"::Transfer;
                        if Rec."From Field No." = 0 then
                            if Rec."Processing Action" = Rec."Processing Action"::Transfer then
                                Rec."Processing Action" := Rec."Processing Action"::Ignore;
                    end;
                end;

        end;
    end;
}