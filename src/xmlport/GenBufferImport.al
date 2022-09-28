xmlport 110001 DMTGenBuffImport
{
    Caption = 'GenBufferImport';
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
            tableelement(GenBuffTable; "DMTGenBuffTable")
            {
                textelement(FieldContent)
                {
                    Unbound = true;
                    trigger OnAfterAssignVariable()
                    var
                        RecRef: RecordRef;
                    begin
                        CurrColIndex += 1;
                        If MaxColCount < (CurrColIndex - 1000) then
                            MaxColCount := (CurrColIndex - 1000);
                        RecRef.GetTable(GenBuffTable);
                        RecRef.Field(GenBuffTable.FieldNo("Import File Path")).Value := CopyStr(CurrPath, 1, Maxstrlen(GenBuffTable."Import File Path"));
                        RecRef.Field(GenBuffTable.FieldNo("Import from Filename")).Value := CopyStr(CurrFileName, 1, Maxstrlen(GenBuffTable."Import from Filename"));
                        RecRef.Field(GenBuffTable.FieldNo("Source ID")).Value := CurrDataFile.RecordID;
                        RecRef.Field(CurrColIndex).Value := FieldContent;
                        RecRef.SetTable(GenBuffTable);
                    end;
                }
                trigger OnBeforeInsertRecord()
                begin
                    ReceivedLinesCount += 1;
                    NextEntryNo += 1;
                    GenBuffTable."Entry No." := NextEntryNo;
                    GenBuffTable."Column Count" := MaxColCount;
                    GenBuffTable.IsCaptionLine := (GenBuffTable."Entry No." = HeaderLineEntryNo);
                end;

                trigger OnAfterInitRecord()
                begin
                    CurrColIndex := 1000; // First Fields starts with 1001
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
                // group(GroupName)
                // {
                //     field(Name; SourceExpression)
                //     {

                //     }
                // }
            }
        }

        actions
        {
        }
    }

    trigger OnPreXmlPort()
    var
        GenBuffTable: Record "DMTGenBuffTable";
    begin
        /* Delete old line on reimport*/
        if CurrFileName <> '' then
            if GenBuffTable.FilterBy(CurrDataFile) then
                GenBuffTable.DeleteAll();

        HeaderLineEntryNo := 1;

        GenBuffTable.Reset();
        if GenBuffTable.FindLast() then begin
            HeaderLineEntryNo := GenBuffTable."Entry No." + 1;
            NextEntryNo := GenBuffTable."Entry No.";
        end;
    end;

    trigger OnPostXmlPort()
    var
        LinesProcessedMsg: Label '%1 Buffer\%2 lines imported';
    begin
        GenBuffTable.UpdateMaxColCount(CurrDataFile, CurrFileName, MaxColCount);
        IF currXMLport.FILENAME <> '' then //only for manual excecution
            MESSAGE(LinesProcessedMsg, currXMLport.FILENAME, ReceivedLinesCount);
    end;

    procedure SetImportFromFile(DataFile: Record DMTDataFile)
    begin
        CurrFileName := DataFile.Name;
        CurrPath := DataFile.Path;
        CurrDataFile := DataFile;
    end;

    var
        CurrDataFile: Record DMTDataFile;
        CurrColIndex: Integer;
        HeaderLineEntryNo: Integer;
        MaxColCount: Integer;
        NextEntryNo: Integer;
        ReceivedLinesCount: Integer;
        CurrFileName, CurrPath : Text;
}