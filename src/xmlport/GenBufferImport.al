xmlport 90000 GenBuffImport
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
                        RecRef.Field(GenBuffTable.FieldNo("Import from Filename")).Value := CopyStr(CurrFileName, 1, Maxstrlen(GenBuffTable."Import from Filename"));
                        RecRef.Field(CurrColIndex).Value := FieldContent;
                        RecRef.SetTable(GenBuffTable);
                    end;
                }
                trigger OnBeforeInsertRecord()
                begin
                    NextEntryNo += 1;
                    GenBuffTable."Entry No." := NextEntryNo;
                    GenBuffTable."Column Count" := MaxColCount;
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
            if GenBuffTable.FilterByFileName(CurrFileName) then begin
                GenBuffTable.DeleteAll();
            end;

        if GenBuffTable.FindLast() then
            NextEntryNo := GenBuffTable."Entry No.";
    end;

    trigger OnPostXmlPort()
    begin
        GenBuffTable.UpdateMaxColCount(CurrFileName, MaxColCount);
    end;


    internal procedure SetFilename(FileNameNew: Text)
    begin
        CurrFileName := FileNameNew;
    end;

    var
        CurrColIndex: Integer;
        NextEntryNo: Integer;
        CurrFileName: Text;
        MaxColCount: Integer;
}