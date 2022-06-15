xmlport 81120 DMTFieldBufferImport
{
    Caption = 'Field';
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
            tableelement(Field; DMTFieldBuffer)
            {
                XmlName = 'Field';
                fieldelement("TableNo"; Field."TableNo") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("No"; Field."No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TableName"; Field."TableName") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FieldName"; Field."FieldName") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Type"; Field."Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Len"; Field."Len") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Class"; Field."Class") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Enabled"; Field."Enabled") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("TypeName"; Field."Type Name") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("FieldCaption"; Field."Field Caption") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RelationTableNo"; Field."RelationTableNo") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("RelationFieldNo"; Field."RelationFieldNo") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("SQLDataType"; Field."SQLDataType") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(TableCaption; Field."Table Caption") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(PrimaryKey; Field."Primary Key") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(OptionString; Field.OptionString) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(OptionCaption; Field.OptionCaption) { FieldValidate = No; MinOccurs = Zero; }
                trigger OnBeforeInsertRecord()
                begin
                    ReceivedLinesCount += 1;
                end;

                trigger OnAfterInitRecord()
                begin
                    if FileHasHeader then begin
                        FileHasHeader := false;
                        currXMLport.Skip();
                    end;
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
                group(Umgebung)
                {
                    Caption = 'Environment';
                    field(GetDatabaseNameCtrl; GetDatabaseName()) { Caption = 'Database'; ApplicationArea = All; }
                    field(COMPANYNAME; COMPANYNAME) { Caption = 'Company'; ApplicationArea = All; }
                }
            }
        }
    }

    trigger OnPostXmlPort()
    var
        LinesProcessedMsg: Label '%1 Buffer\%2 lines imported';
    begin
        IF currXMLport.FILENAME <> '' then //only for manual excecution
            MESSAGE(LinesProcessedMsg, Field.TABLECAPTION, ReceivedLinesCount);
    end;

    trigger OnPreXmlPort()
    begin
        ClearBufferBeforeImportTable(Database::DMTFieldBuffer);
        FileHasHeader := true;
    end;

    var
        ReceivedLinesCount: Integer;
        FileHasHeader: Boolean;

    procedure GetFieldCaption(_TableNo: Integer; _FieldNo: Integer) _FieldCpt: Text[1024]
    var
        _Field: Record "Field";
    begin
        IF _TableNo = 0 then exit('');
        IF _FieldNo = 0 then exit('');
        IF NOT _Field.GET(_TableNo, _FieldNo) then exit('');
        _FieldCpt := _Field."Field Caption";
    end;

    procedure RemoveSpecialChars(TextIn: Text[1024]) TextOut: Text[1024]
    var
        CharArray: Text[30];
    begin
        CharArray[1] := 9; // TAB
        CharArray[2] := 10; // LF
        CharArray[3] := 13; // CR
        exit(DELCHR(TextIn, '=', CharArray));
    end;

    local procedure ClearBufferBeforeImportTable(BufferTableNo: Integer)
    var
        BufferRef: RecordRef;
    begin
        //* Puffertabelle l”schen vor dem Import
        IF NOT currXMLport.IMPORTFILE then
            EXIT;
        IF BufferTableNo < 50000 then begin
            MESSAGE('Achtung: Puffertabellen ID kleiner 50000');
            EXIT;
        end;
        BufferRef.OPEN(BufferTableNo);
        IF NOT BufferRef.IsEmpty then
            BufferRef.DeleteAll();
    end;

    procedure GetDatabaseName(): Text[250]
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SetRange("Server Instance ID", SERVICEINSTANCEID());
        ActiveSession.SetRange("Session ID", SESSIONID());
        ActiveSession.FINDFIRST();
        exit(ActiveSession."Database Name");
    end;
}
