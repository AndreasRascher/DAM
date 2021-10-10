table 91002 "DAMFields"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(20; "From Table ID"; Integer)
        {
            CaptionML = DEU = 'Herkunft Tabellen ID', ENU = 'Source Table ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(21; "From Field No."; Integer)
        {
            CaptionML = DEU = 'Herkunft Feldnr.', ENU = 'Source Field No.';
            DataClassification = SystemMetadata;
            TableRelation = Field."No." WHERE(TableNo = field("From Table ID"));
            trigger OnValidate()
            begin
                UpdateProcessingAction(Rec.FieldNo("From Field No."));
            end;
        }
        field(22; "From Field Caption"; Text[80])
        {
            CaptionML = DEU = 'Herkunftsfeld Bezeichnung', ENU = 'Source Field Caption';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("From Table ID"), "No." = field("From Field No.")));
            TableRelation = Field."No." WHERE(TableNo = field("From Table ID"));
        }
        field(23; "From Field Type"; Text[30])
        {
            CaptionML = DEU = 'Herkunftsfeld Typ', ENU = 'Source Field Type';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Type Name" where(TableNo = field("From Table ID"), "No." = field("From Field No.")));
            TableRelation = Field."No." WHERE(TableNo = field("From Table ID"));
        }
        field(30; "To Table ID"; Integer)
        {
            CaptionML = DEU = 'Ziel Tabellen ID', ENU = 'Target Table ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(31; "To Field No."; Integer)
        {
            CaptionML = DEU = 'Ziel Feldnr.', ENU = 'Target Field No.';
            DataClassification = SystemMetadata;
            TableRelation = Field."No." WHERE(TableNo = field("To Table ID"));
        }
        field(32; "To Field Caption"; Text[80])
        {
            CaptionML = DEU = 'Zielfeld Bezeichnung', ENU = 'Target Field Caption';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("To Table ID"), "No." = field("To Field No.")));
            TableRelation = Field."No." WHERE(TableNo = field("To Table ID"));
        }
        field(33; "To Field Type"; Text[30])
        {
            CaptionML = DEU = 'Zielfeld Typ', ENU = 'Target Field Type';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Type Name" where(TableNo = field("To Table ID"), "No." = field("To Field No.")));
            TableRelation = Field."No." WHERE(TableNo = field("To Table ID"));
        }
        field(34; "Fixed Value"; Text[250])
        {
            CaptionML = DEU = 'Fester Wert', ENU = 'Fixed Value';
            trigger OnValidate()
            begin
                UpdateProcessingAction(Rec.FieldNo("Fixed Value"));
            end;
        }
        field(50; "Validate Value"; Boolean)
        {
            CaptionML = DEU = 'Validieren', ENU = 'Validate';
            InitValue = true;
        }
        field(51; "Validate Method"; Option)
        {
            OptionMembers = "Field Validate","Try function","if codeunit run";
            OptionCaptionML = DEU = 'Feld Validierung,try function,if codeunit run', ENU = 'Field Validate,try function,if codeunit run';
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
        key(PK; "From Table ID", "To Table ID", "To Field No.")
        {
            Clustered = true;
        }
    }
    internal procedure FilterBy(DAMTable: Record DAMTable) NotIsEmpty: Boolean
    begin
        Rec.SetRange("From Table ID", DAMTable."From Table ID");
        Rec.SetRange("To Table ID", DAMTable."To Table ID");
        NotIsEmpty := not Rec.IsEmpty;
    end;

    internal procedure InitForTargetTable(DAMTable: Record DAMTable): Boolean
    var
        DAMFields: Record DAMFields;
        DAMFields_NEW: Record DAMFields;
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
                        DAMFields_NEW."From Table ID" := DAMTable."From Table ID";
                        DAMFields_NEW."To Field No." := TargetRecRef.FieldIndex(i).Number;
                        DAMFields_NEW."To Table ID" := DAMTable."To Table ID";
                        DAMFields_NEW.Insert(true);
                    end;
                end;
        end;
    end;

    internal procedure ProposeMatchingTargetFields(DAMTable: Record DAMTable): Boolean
    var
        SourceField: Record Field;
        TargetField: Record Field;
        DAMFields: Record DAMFields;
        DAMFields2: Record DAMFields;
        OldFieldName: text;
        Found: Boolean;
    begin
        DAMFields.FilterBy(DAMTable);
        DAMFields.setrange("From Field No.", 0);
        if DAMFields.FindSet(false, false) then
            repeat
                TargetField.Get(DAMFields."To Table ID", DAMFields."To Field No.");
                SourceField.SetRange(TableNo, DAMTable."From Table ID");
                SourceField.SetRange(Enabled, true);
                SourceField.SetRange(Class, SourceField.Class::Normal);
                SourceField.SetRange(FieldName, TargetField.FieldName);
                Found := SourceField.FindFirst();
                if not Found then
                    if FindFieldNameInOldVersion(TargetField, DAMFields."To Table ID", OldFieldName) then begin
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
        DAMFields: Record DAMFields;
        DAMFields2: Record DAMFields;
    begin
        DAMFields.FilterBy(DAMTable);
        DAMFields.SetRange("Processing Action", DAMFields."Processing Action"::Transfer);
        if DAMFields.FindSet(false, false) then
            repeat
                TargetField.Get(DAMFields."To Table ID", DAMFields."To Field No.");
                DAMFields2 := DAMFields;
                case true of
                    TargetField.FieldName IN ['Global Dimension 1 Code',
                                              'Global Dimension 2 Code',
                                              'VAT Registration No.']:
                        begin
                            DAMFields2."Validate Method" := DAMFields2."Validate Method"::"if codeunit run";
                        end;
                    (TargetField.TableNo = DATabase::Item) and
                    (TargetField.FieldName IN ['Costing Method', 'Tariff No.', 'Base Unit of Measure']):
                        begin
                            DAMFields2."Validate Method" := DAMFields2."Validate Method"::"if codeunit run";
                        end;
                    (TargetField.TableNo IN [Database::Customer, Database::Vendor]) and
                    (TargetField.FieldName IN ['Primary Contact No.', 'Contact']):
                        begin
                            DAMFields2."Validate Value" := false;
                        end;
                end;

                if format(DAMFields2) <> Format(DAMFields) then
                    DAMFields2.Modify()
            until DAMFields.Next() = 0;
    end;

    procedure FindFieldNameInOldVersion(TargetField: Record Field;
        TargetTableNo: Integer; VAR
                                    OldFieldName: Text) Found: Boolean
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