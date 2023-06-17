xmlport 73002 DMTCSVImport
{
    Caption = 'CSV Import', Locked = true;
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
            tableelement(GenBuffTable; DMTGenBuffTable)
            {
                textelement(FieldContent)
                {
                    Unbound = true;
                    trigger OnAfterAssignVariable()
                    begin
                        CurrColIndexGlobal += 1;
                        UpdateMaxColCount(CurrColIndexGlobal);
                        AssignFieldValue(NewLineGlobal, FieldContent, CurrColIndexGlobal);
                    end;
                }

                trigger OnBeforeInsertRecord()
                begin
                    LineCountGlobal += 1;
                    NewLineGlobal."Entry No." += 1;
                    NewLineGlobal."Column Count" := MaxColCountGlobal;
                    NewLineGlobal.IsCaptionLine := (LineCountGlobal = HeaderLineNoGlobal);
                end;

                trigger OnAfterInitRecord()
                begin
                    if DoSkipLine(LineCountGlobal) then
                        currXMLport.skip();
                    SetupNewLine(NewLineGlobal);
                    CurrColIndexGlobal := 1000; // First Fields starts with 1001
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    var
        GenBuffTable: Record DMTGenBuffTable;
    begin
        /* Delete old line on reimport*/
        if GenBuffTable."Import File Path" <> '' then
            if GenBuffTable.FilterBy(CurrDataFile) then
                GenBuffTable.DeleteAll();
        /* Get Next Entry No.*/
        NewLineGlobal."Entry No." := GetNextEntryNo(GenBuffTable);
    end;

    trigger OnPostXmlPort()
    var
        genBuffTable: Record DMTGenBuffTable;
        linesProcessedMsg: Label '%1 Buffer\%2 lines imported';
    begin
        genBuffTable.UpdateMaxColCount(CurrDataFile, CurrDataFile.Name, MaxColCountGlobal);
        if currXMLport.Filename <> '' then //only for manual excecution
            Message(linesProcessedMsg, currXMLport.Filename, LineCountGlobal);
    end;

    local procedure UpdateMaxColCount(CurrColIndex: Integer)
    begin
        if MaxColCountGlobal < (CurrColIndex - 1000) then
            MaxColCountGlobal := (CurrColIndex - 1000);
    end;

    local procedure DoSkipLine(CurrLine: Integer): Boolean
    begin
        if SpecificLinesToImportList.Count > 0 then
            if not SpecificLinesToImportList.Contains(CurrLine) then
                exit(true);
    end;

    local procedure GetNextEntryNo(var GenBuffTable: Record DMTGenBuffTable) NextEntryNo: Integer
    begin
        NextEntryNo := 1;
        GenBuffTable.Reset();
        if GenBuffTable.FindLast() then begin
            NextEntryNo += GenBuffTable."Entry No.";
        end;
    end;

    local procedure SetupNewLine(var NewLine: Record DMTGenBuffTable)
    var
        PreviousLineEntryNo: Integer;
    begin
        PreviousLineEntryNo := NewLine."Entry No.";
        Clear(NewLine);
        NewLine."Entry No." := PreviousLineEntryNo + 1;
        NewLine."Source ID" := DefaultLineValues."Source ID";
        NewLine."Import File Path" := DefaultLineValues."Import File Path";
        NewLine."Import from Filename" := DefaultLineValues."Import from Filename";
    end;

    local procedure AssignFieldValue(var Line: Record DMTGenBuffTable; FieldValue: Text; ColIndex: Integer)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Line);
        RecRef.Field(ColIndex).Value := FieldValue;
        RecRef.SetTable(Line);
    end;

    procedure SetOrAddSpecificImportLineNo(LineNo: Integer)
    begin
        if not SpecificLinesToImportList.Contains(LineNo) then
            SpecificLinesToImportList.Add(LineNo);
    end;

    procedure SetHeaderLineNo(HeaderLineNoNew: Integer)
    begin
        HeaderLineNoGlobal := HeaderLineNoNew;
    end;

    procedure SetSourceFileProperties(FilePath: Text; FileName: Text; DataFile: Record DMTDataFile)
    begin
        Clear(DefaultLineValues);
        DefaultLineValues."Import File Path" := CopyStr(FilePath, 1, MaxStrLen(GenBuffTable."Import File Path"));
        DefaultLineValues."Import from Filename" := CopyStr(FileName, 1, MaxStrLen(GenBuffTable."Import from Filename"));
        DefaultLineValues."Source ID" := DataFile.RecordId;
        CurrDataFile := DataFile;
    end;

    var
        NewLineGlobal, DefaultLineValues : Record DMTGenBuffTable;
        CurrDataFile: Record DMTDataFile;
        HeaderLineNoGlobal, MaxColCountGlobal, CurrColIndexGlobal, LineCountGlobal : Integer;
        SpecificLinesToImportList: List of [Integer];
}