table 110010 DMTProcessingPlan
{
    DataClassification = ToBeClassified;
    Caption = 'DMTProcessingPlan', Locked = true;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Line Type"; Option)
        {
            Caption = 'Line Type';
            OptionMembers = " ","Group";
            trigger OnValidate()
            begin
                if xRec."Line Type" = xRec."Line Type"::" " then
                    if Rec."Line Type" = Rec."Line Type"::Group then begin
                        Clear(Description);
                        Clear(DataFileID);
                    end;
            end;
        }
        field(11; DataFileID; Integer)
        {
            Caption = 'DataFile ID';
            TableRelation = DMTDataFile.ID;
            trigger OnValidate()
            var
                DMTDataFile: Record DMTDataFile;
            begin
                case true of
                    (xRec.DataFileID <> 0) and (Rec.DataFileID = 0):
                        Description := '';
                    (Rec.DataFileID <> 0):
                        begin
                            DMTDataFile.Get(Rec.DataFileID);
                            Description := DMTDataFile.Name;
                        end;
                end;
            end;
        }
        field(12; Description; Text[250]) { Caption = 'Description'; }
        field(20; "Action"; Option) { OptionMembers = " ","Import To Buffer","Import To Target","Update Field"; }
        field(30; "Source Table Filter"; Blob) { Caption = 'Source Table Filter Blob', Locked = true; }
        field(31; "Update Fields Filter"; Text[250]) { Caption = 'Update Fields Filter', Locked = true; }
        field(32; "Default Field Values"; Blob) { Caption = 'Default Field Values', Locked = true; }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }

    local procedure SaveViewToFilterText(DataFile: record DmtDataFile; var RecRef: RecordRef)
    var
        TableFilterPage: Page "Table Filter";
        FldRef: FieldRef;
        FldIndex: Integer;
        TextFieldFilter: Text;
        FirstFieldIDWithFilter: Integer;
        TextTableFilter: Text;
    begin
        for FldIndex := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(FldIndex);
            if FldRef.GetFilter <> '' then begin
                if FirstFieldIDWithFilter = 0 then
                    FirstFieldIDWithFilter := FldRef.Number;
                TextFieldFilter := CreateTextFieldFilter(FldRef);
                if StrLen(TextFieldFilter) > 0 then begin
                    if (FirstFieldIDWithFilter <> 0) and (FirstFieldIDWithFilter < FldRef.Number) then
                        TextTableFilter += ',';
                    AppendFieldFilter(TextTableFilter, TextFieldFilter);
                end;
            end;
        end;
        if StrLen(TextFieldFilter) > 0 then
            TextTableFilter := QuoteValue('Filter:', ':') + ': ' + TextFieldFilter;
        if TextTableFilter <> '' then
            Evaluate(Rec."Source Table Filter", TextTableFilter);
    end;

    local procedure CreateTextFieldFilter(var FldRef: FieldRef): Text
    begin
        if (FldRef.Number > 0) and (StrLen(FldRef.GetFilter()) > 0) then
            exit(QuoteValue(FldRef.Caption, '=') + '=' + QuoteValue(FldRef.GetFilter(), ','));
        exit('');
    end;

    local procedure QuoteValue(TextValue: Text; TextCausingQuotes: Text): Text
    var
        InnerQuotePosition: Integer;
        TextValue2: Text;
    begin
        // If quotes are not needed return initial value:
        if not TextValue.Contains(TextCausingQuotes) then
            exit(TextValue);

        // Escape possible double quote characters:
        InnerQuotePosition := StrPos(TextValue, '"');
        while InnerQuotePosition > 0 do begin
            TextValue2 += CopyStr(TextValue, 1, InnerQuotePosition) + '"';
            TextValue := CopyStr(TextValue, InnerQuotePosition + 1, StrLen(TextValue));
            InnerQuotePosition := StrPos(TextValue, '"');
        end;

        // Surround by double quotes:
        TextValue2 += TextValue;
        TextValue2 := '"' + TextValue2 + '"';

        exit(TextValue2);
    end;

    local procedure AppendFieldFilter(var TextTableFilter: Text; TextFieldFilter: Text)
    begin
        TextTableFilter += TextFieldFilter;
    end;

    procedure EditSourceTableFilter()
    var
        DataFile: Record DMTDataFile;
        Import: Codeunit DMTImport;
        BufferRef: RecordRef;
    begin
        DataFile.Get(Rec.DataFileID);
        Import.InitBufferRef(DataFile, BufferRef);
        if Import.ShowRequestPageFilterDialog(BufferRef, DataFile) then begin
            SaveViewToFilterText(DataFile, BufferRef);
        end;
    end;

    procedure ReadSourceTableView() SourceTableView: Text
    var
        IStr: InStream;
    begin
        rec.calcfields("Source Table Filter");
        if not rec."Source Table Filter".HasValue then exit('');
        rec."Source Table Filter".CreateInStream(IStr);
        IStr.ReadText(SourceTableView);
    end;

    procedure SaveSourceTableFilter(SourceTableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Source Table Filter");
        Rec.Modify();
        rec."Source Table Filter".CreateOutStream(Ostr);
        OStr.WriteText(SourceTableView);
        Rec.Modify();
    end;
}