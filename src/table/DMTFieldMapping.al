table 110041 DMTFieldMapping
{
    fields
    {
        field(1; "Data File ID"; Integer)
        {
            Caption = 'Datafile ID';
            TableRelation = DMTDataFile.ID;
        }
        field(10; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', comment = 'Ziel Tabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(11; "Target Field No."; Integer)
        {
            Caption = 'Target Field No.', comment = 'Ziel Feldnr.';
            TableRelation = Field."No." WHERE(TableNo = field("Target Table ID"));
        }
        field(12; "Target Field Caption"; Text[80])
        {
            Caption = 'Target Field Caption', comment = 'Zielfeld Bezeichnung';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Target Table ID"), "No." = field("Target Field No.")));
        }
        field(13; "Target Field Name"; Text[80])
        {
            Caption = 'Target Field Name', comment = 'Zielfeld Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."FieldName" where(TableNo = field("Target Table ID"), "No." = field("Target Field No.")));
        }
        field(14; "Is Key Field(Target)"; Boolean) { Caption = 'Key Field', Comment = 'Schlüsselfeld'; Editable = false; }
        field(30; "Source Table ID"; Integer)
        {
            Caption = 'Source Table ID', comment = 'Herkunft Tabellen ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(31; "Source Field No."; Integer)
        {
            Caption = 'Source Field No.', comment = 'Herkunftsfeld Nr.';
            TableRelation = DMTFieldBuffer."No." where("Data File ID Filter" = field("Data File ID"));
            ValidateTableRelation = false;
            BlankZero = true;
            trigger OnValidate()
            begin
                if CurrFieldNo = Rec.FieldNo("Source Field No.") then
                    UpdateSourceFieldCaption();
                UpdateProcessingAction(Rec.FieldNo("Source Field No."));
            end;
        }
        field(32; "Source Field Caption"; Text[80]) { Caption = 'Source Field Caption', comment = 'Herkunftsfeld Bezeichnung'; Editable = false; }
        field(40; "Replacements Code"; Code[50]) { Caption = 'Replacements Code', comment = 'Ersetzungen Code'; TableRelation = DMTReplacementsHeader.Code; }
        field(50; "Validation Type"; enum "DMTFieldValidationType") { Caption = 'Valid. Type', comment = 'Valid. Typ'; }
        field(52; "Ignore Validation Error"; Boolean) { Caption = 'Ignore Errors', comment = 'Fehler ignorieren '; }
        field(100; "Processing Action"; enum DMTFieldProcessingType) { Caption = 'Action', comment = 'Aktion'; }
        field(101; "Fixed Value"; Text[250])
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
                    if ErrorMsg <> '' then begin
                        Error(ErrorMsg);
                    end else begin
                        "Fixed Value" := Format(FldRef.Value);
                    end;
                end;
                // UpdateProcessingAction(Rec.FieldNo("Fixed Value"));
            end;
        }
        field(102; "Validation Order"; Integer) { Caption = 'Validation Order', comment = 'Reihenfolge Validierung'; }
        field(103; Comment; Text[250]) { Caption = 'Comment', Comment = 'Bemerkung'; }
    }

    keys
    {
        key(Key1; "Data File ID", "Target Field No.") { Clustered = true; }
        key(ValidationOrder; "Validation Order") { }
    }
    procedure CopyToTemp(var TempFieldMapping: Record DMTFieldMapping temporary) LineCount: Integer
    var
        FieldMapping: Record DMTFieldMapping;
        TempFieldMapping2: Record DMTFieldMapping temporary;
    begin
        FieldMapping.Copy(Rec);
        if FieldMapping.FindSet(false, false) then
            repeat
                LineCount += 1;
                TempFieldMapping2 := FieldMapping;
                TempFieldMapping2.Insert(false);
            until FieldMapping.Next() = 0;
        TempFieldMapping.Copy(TempFieldMapping2, true);
    end;

    procedure UpdateSourceFieldCaption()
    var
        DataFile: Record DMTDataFile;
        FieldMapping: Record DMTFieldMapping;
        DMTGenBuffTable: Record DMTGenBuffTable;
        SourceField, TargetField : Record Field;
        BuffTableCaptions: Dictionary of [Integer, Text];
        BuffTableCaption: Text;
    begin
        if Rec."Source Field No." = 0 then begin
            Rec."Source Field Caption" := '';
            exit;
        end;
        FieldMapping := Rec;
        DataFile.get(Rec."Target Table ID");
        case DataFile.BufferTableType of
            DataFile.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    DMTGenBuffTable.GetColCaptionForImportedFile(DataFile, BuffTableCaptions);
                    if BuffTableCaptions.Get(Rec."Source Field No." - 1000, BuffTableCaption) then begin
                        TargetField.SetRange(TableNo, Rec."Target Table ID");
                        TargetField.SetFilter(FieldName, ConvertStr(BuffTableCaption, '@()&', '????'));
                        if (TargetField.Count() = 1) then begin
                            Rec."Source Field Caption" := CopyStr(BuffTableCaption, 1, MaxStrLen(Rec."Source Field Caption"));
                        end;
                    end;
                end;
            DataFile.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    Rec.TestField("Target Table ID");
                    if SourceField.Get(Rec."Source Table ID", Rec."Source Field No.") then
                        Rec."Source Field Caption" := CopyStr(SourceField."Field Caption", 1, MaxStrLen(Rec."Source Field Caption"));
                end;
        end;
        if Format(FieldMapping) <> Format(Rec) then
            Rec.Modify();
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
}