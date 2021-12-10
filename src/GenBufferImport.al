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
            tableelement(GenBuffTable; DAMGenBuffTable)
            {
                textelement(FieldContent)
                {
                    Unbound = true;
                    trigger OnAfterAssignVariable()
                    var
                        RecRef: RecordRef;
                    begin
                        CurrColIndex += 1;
                        RecRef.GetTable(GenBuffTable);
                        RecRef.Field(CurrColIndex).Value := FieldContent;
                        RecRef.SetTable(GenBuffTable);
                    end;
                }
                trigger OnBeforeInsertRecord()
                begin
                    GenBuffTable."Entry No." := LastEntryNo + 1;
                    LastEntryNo += 1;
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
            area(processing)
            {
                action(ActionName)
                {

                }
            }
        }
    }

    trigger OnPreXmlPort()
    var
        GenBuffTable: Record DAMGenBuffTable;
    begin
        if GenBuffTable.FindLast() then
            LastEntryNo := GenBuffTable."Entry No.";
    end;

    var
        CurrColIndex: Integer;
        LastEntryNo: Integer;
}