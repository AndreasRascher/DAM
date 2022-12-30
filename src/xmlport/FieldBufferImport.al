xmlport 110000 DMTFieldBufferImport
{
    Caption = 'Field';
    Direction = Import;
    FieldSeparator = '<TAB>';
    FieldDelimiter = '<None>';
    TextEncoding = UTF8;
    Format = VariableText;
    FormatEvaluate = Xml;

    schema
    {
        textelement(Root)
        {
            tableelement(Field; DMTFieldBuffer)
            {
                XmlName = 'Field';
                fieldelement(TableNo; Field.TableNo) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(No; Field."No.") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(TableName; Field.TableName) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(FieldName; Field.FieldName) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Type"; Field."Type") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(Len; Field.Len) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(Class; Field.Class) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(Enabled; Field.Enabled) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(TypeName; Field."Type Name") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(FieldCaption; Field."Field Caption") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(RelationTableNo; Field.RelationTableNo) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(RelationFieldNo; Field.RelationFieldNo) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(SQLDataType; Field.SQLDataType) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(TableCaption; Field."Table Caption") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(PrimaryKey; Field."Primary Key") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(OptionString; Field.OptionString) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(OptionCaption; Field.OptionCaption) { FieldValidate = No; MinOccurs = Zero; }
                fieldelement(NoOfRecords; Field."No. of Records") { FieldValidate = No; MinOccurs = Zero; }
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
            area(Content)
            {
                group(Umgebung)
                {
                    Caption = 'Environment';
                    field(GetDatabaseNameCtrl; GetDatabaseName()) { Caption = 'Database'; ApplicationArea = All; }
                    field(COMPANYNAME; CompanyName) { Caption = 'Company'; ApplicationArea = All; }
                }
            }
        }
    }

    trigger OnPostXmlPort()
    var
        LinesProcessedMsg: Label '%1 Buffer\%2 lines imported';
    begin
        if currXMLport.Filename <> '' then //only for manual excecution
            Message(LinesProcessedMsg, Field.TableCaption, ReceivedLinesCount);
    end;

    trigger OnPreXmlPort()
    begin
        ClearBufferBeforeImportTable(Database::DMTFieldBuffer);
        FileHasHeader := true;
    end;

    var
        FileHasHeader: Boolean;
        ReceivedLinesCount: Integer;

    procedure GetFieldCaption(_TableNo: Integer; _FieldNo: Integer) _FieldCpt: Text[1024]
    var
        _Field: Record "Field";
    begin
        if _TableNo = 0 then exit('');
        if _FieldNo = 0 then exit('');
        if not _Field.Get(_TableNo, _FieldNo) then exit('');
        _FieldCpt := _Field."Field Caption";
    end;

    procedure RemoveSpecialChars(TextIn: Text[1024]) TextOut: Text[1024]
    var
        CharArray: Text[30];
    begin
        CharArray[1] := 9; // TAB
        CharArray[2] := 10; // LF
        CharArray[3] := 13; // CR
        exit(DelChr(TextIn, '=', CharArray));
    end;

    local procedure ClearBufferBeforeImportTable(BufferTableNo: Integer)
    var
        BufferRef: RecordRef;
    begin
        //* Puffertabelle l”schen vor dem Import
        if not currXMLport.ImportFile then
            exit;
        if BufferTableNo < 50000 then begin
            Message('Achtung: Puffertabellen ID kleiner 50000');
            exit;
        end;
        BufferRef.Open(BufferTableNo);
        if not BufferRef.IsEmpty then
            BufferRef.DeleteAll();
    end;

    procedure GetDatabaseName(): Text[250]
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SetRange("Server Instance ID", ServiceInstanceId());
        ActiveSession.SetRange("Session ID", SessionId());
        ActiveSession.FindFirst();
        exit(ActiveSession."Database Name");
    end;
}
