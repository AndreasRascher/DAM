codeunit 91003 "DMTObjectGenerator"
{
    procedure GetNavClassicDataport(ObjectID: Integer) Content: text;
    var
        DMTExportObject: Record DMTExportObject;
        DMTSetup: Record "DMTSetup";
        BigTextContent: BigText;
        IStr: instream;
    begin
        DMTExportObject.get();
        DMTSetup.Get();
        DMTSetup.TestField("Object ID Export Object");
        DMTExportObject.CalcFields(ExportDataPort);
        DMTExportObject.ExportDataPort.CreateInStream(IStr);
        BigTextContent.Read(IStr);
        BigTextContent.GetSubText(Content, 1);
        Content := Content.Replace('OBJECT Dataport 50004 DMTExport',
                                   'OBJECT Dataport ' + Format(DMTSetup."Object ID Export Object") + ' DMTExport')
    end;

    procedure GetNAVRTCXMLPort(ObjectID: Integer) Content: text;
    var
        DMTExportObject: Record DMTExportObject;
        DMTSetup: Record "DMTSetup";
        BigTextContent: BigText;
        IStr: instream;
    begin
        DMTExportObject.Get();
        DMTSetup.get();
        DMTSetup.TestField("Object ID Export Object");
        DMTExportObject.CalcFields(ExportXMLPort);
        DMTExportObject.ExportDataPort.CreateInStream(IStr);
        BigTextContent.Read(IStr);
        BigTextContent.GetSubText(Content, 1);

        Content := Content.Replace('OBJECT XMLport 50022 DMT Export',
                                   'OBJECT XMLport ' + Format(DMTSetup."Object ID Export Object") + ' DMT Export');
        Content := Content.Replace('dmtExport@1000000002 : XMLport 50022;',
                                   'dmtExport@1000000002 : XMLport ' + Format(DMTSetup."Object ID Export Object") + ';')
    end;

    procedure CreateALXMLPort(DMTTable: Record DMTTable) C: TextBuilder
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
    begin
        DMTTable.Testfield("Import XMLPort ID");
        DMTTable.Testfield("Old Version Table ID");

        C.AppendLine('xmlport ' + format(DMTTable."Import XMLPort ID") + ' T' + format(DMTTable."Old Version Table ID") + 'Import');
        C.AppendLine('{');
        C.AppendLine('    Caption = ''' + DMTTable."Old Version Table Caption" + ''';');
        C.AppendLine('    Direction = Import;');
        C.AppendLine('    FieldSeparator = ''<TAB>'';');
        C.AppendLine('    FieldDelimiter = ''<None>'';');
        C.AppendLine('    TextEncoding = UTF16;');
        C.AppendLine('    Format = VariableText;');
        C.AppendLine('    FormatEvaluate = Xml;');
        C.AppendLine('');
        C.AppendLine('    schema');
        C.AppendLine('    {');
        C.AppendLine('        textelement(Root)');
        C.AppendLine('        {');

        IF FilterFields(DMTFieldBuffer, DMTTable."Old Version Table ID", FALSE, true, FALSE) THEN BEGIN
            C.AppendLine('            tableelement(' + GetCleanTableName(DMTFieldBuffer) + '; ' + STRSUBSTNO('T%1Buffer', DMTTable."Old Version Table ID") + ')');
            C.AppendLine('            {');
            C.AppendLine('                XmlName = ''' + GetCleanTableName(DMTFieldBuffer) + ''';');
            DMTFieldBuffer.FINDSET();
            REPEAT
                C.AppendLine('                fieldelement("' + GetCleanFieldName(DMTFieldBuffer) + '"; ' + GetCleanTableName(DMTFieldBuffer) + '."' + DMTFieldBuffer.FieldName + '") { FieldValidate = No; MinOccurs = Zero; }');
            UNTIL DMTFieldBuffer.NEXT() = 0;
        END;

        C.AppendLine('                trigger OnBeforeInsertRecord()');
        C.AppendLine('                begin');
        C.AppendLine('                    ReceivedLinesCount += 1;');
        C.AppendLine('                end;');
        C.AppendLine('');
        C.AppendLine('                trigger OnAfterInitRecord()');
        C.AppendLine('                begin');
        C.AppendLine('                    if FileHasHeader then begin');
        C.AppendLine('                        FileHasHeader := false;');
        C.AppendLine('                        currXMLport.Skip();');
        C.AppendLine('                    end;');
        C.AppendLine('                end;');
        C.AppendLine('            }');
        C.AppendLine('        }');
        C.AppendLine('    }');
        C.AppendLine('');
        C.AppendLine('    requestpage');
        C.AppendLine('    {');
        C.AppendLine('        layout');
        C.AppendLine('        {');
        C.AppendLine('            area(content)');
        C.AppendLine('            {');
        C.AppendLine('                group(Umgebung)');
        C.AppendLine('                {');
        C.AppendLine('                    Caption = ''Environment'';');
        C.AppendLine('                    field(DatabaseName; GetDatabaseName()) { Caption = ''Database''; ApplicationArea = all; }');
        C.AppendLine('                    field(COMPANYNAME; COMPANYNAME) { Caption = ''Company''; ApplicationArea = all; }');
        C.AppendLine('                }');
        C.AppendLine('            }');
        C.AppendLine('        }');
        C.AppendLine('    }');
        C.AppendLine('');
        C.AppendLine('    trigger OnPostXmlPort()');
        C.AppendLine('    var');
        C.AppendLine('        LinesProcessedMsg: Label ''%1 Buffer\%2 lines imported'';');
        C.AppendLine('        ' + STRSUBSTNO('T%1Buffer', DMTTable."Old Version Table ID") + ': Record ' + STRSUBSTNO('T%1Buffer', DMTTable."Old Version Table ID") + ';');
        C.AppendLine('    begin');
        C.AppendLine('        IF currXMLport.FILENAME <> '''' then //only for manual excecution');
        C.AppendLine('            MESSAGE(LinesProcessedMsg, ' + STRSUBSTNO('T%1Buffer', DMTTable."Old Version Table ID") + '.TABLECAPTION, ReceivedLinesCount);');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    trigger OnPreXmlPort()');
        C.AppendLine('    var');
        C.AppendLine('        ' + STRSUBSTNO('T%1Buffer', DMTTable."Old Version Table ID") + ': Record ' + STRSUBSTNO('T%1Buffer', DMTTable."Old Version Table ID") + ';');
        C.AppendLine('    begin');
        C.AppendLine('        ClearBufferBeforeImportTable(' + STRSUBSTNO('T%1Buffer', DMTTable."Old Version Table ID") + '.RECORDID.TABLENO);');
        C.AppendLine('        FileHasHeader := true;');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    var');
        C.AppendLine('        ReceivedLinesCount: Integer;');
        C.AppendLine('        FileHasHeader: Boolean;');
        C.AppendLine('');
        C.AppendLine('    procedure GetFieldCaption(_TableNo: Integer;');
        C.AppendLine('    _FieldNo: Integer) _FieldCpt: Text[1024]');
        C.AppendLine('    var');
        C.AppendLine('        _Field: Record "Field";');
        C.AppendLine('    begin');
        C.AppendLine('        IF _TableNo = 0 then exit('''');');
        C.AppendLine('        IF _FieldNo = 0 then exit('''');');
        C.AppendLine('        IF NOT _Field.GET(_TableNo, _FieldNo) then exit('''');');
        C.AppendLine('        _FieldCpt := _Field."Field Caption";');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    procedure RemoveSpecialChars(TextIn: Text[1024]) TextOut: Text[1024]');
        C.AppendLine('    var');
        C.AppendLine('        CharArray: Text[30];');
        C.AppendLine('    begin');
        C.AppendLine('        CharArray[1] := 9; // TAB');
        C.AppendLine('        CharArray[2] := 10; // LF');
        C.AppendLine('        CharArray[3] := 13; // CR');
        C.AppendLine('        exit(DELCHR(TextIn, ''='', CharArray));');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    local procedure ClearBufferBeforeImportTable(BufferTableNo: Integer)');
        C.AppendLine('    var');
        C.AppendLine('        BufferRef: RecordRef;');
        C.AppendLine('    begin');
        C.AppendLine('        //* Puffertabelle l”schen vor dem Import');
        C.AppendLine('        IF NOT currXMLport.IMPORTFILE then');
        C.AppendLine('            exit;');
        C.AppendLine('        IF BufferTableNo < 50000 then begin');
        C.AppendLine('            MESSAGE(''Achtung: Puffertabellen ID kleiner 50000'');');
        C.AppendLine('            exit;');
        C.AppendLine('        end;');
        C.AppendLine('        BufferRef.OPEN(BufferTableNo);');
        C.AppendLine('        IF NOT BufferRef.IsEmpty then');
        C.AppendLine('            BufferRef.DELETEALL();');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    procedure GetDatabaseName(): Text[250]');
        C.AppendLine('    var');
        C.AppendLine('        ActiveSession: Record "Active Session";');
        C.AppendLine('    begin');
        C.AppendLine('        ActiveSession.SETRANGE("Server Instance ID", SERVICEINSTANCEID());');
        C.AppendLine('        ActiveSession.SETRANGE("Session ID", SESSIONID());');
        C.AppendLine('        ActiveSession.findfirst();');
        C.AppendLine('        exit(ActiveSession."Database Name");');
        C.AppendLine('    end;');
        C.AppendLine('}');
    end;

    procedure CreateALTable(DMTTable: Record DMTTable) C: TextBuilder
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        _FieldTypeText: Text;
    begin
        DMTTable.testfield("Buffer Table ID");
        DMTTable.TestField("Old Version Table ID");
        FilterFields(DMTFieldBuffer, DMTTable."Old Version Table ID", FALSE, true, FALSE);
        C.AppendLine('table ' + FORMAT(DMTTable."Buffer Table ID") + ' ' + STRSUBSTNO('T%1Buffer', DMTTable."Old Version Table ID"));
        C.AppendLine('{');
        C.AppendLine('    CaptionML= DEU = ''' + DMTTable."Old Version Table Caption" + '(DMT)' + ''', ENU = ''' + DMTFieldBuffer.TableName + '(DMT)' + ''';');
        C.AppendLine('  fields {');
        IF FilterFields(DMTFieldBuffer, DMTTable."Old Version Table ID", FALSE, true, FALSE) THEN
            REPEAT
                CASE DMTFieldBuffer.Type OF
                    DMTFieldBuffer.Type::Code, DMTFieldBuffer.Type::Text:
                        _FieldTypeText := STRSUBSTNO('%1[%2]', DMTFieldBuffer.Type, DMTFieldBuffer.Len);
                    ELSE
                        _FieldTypeText := FORMAT(DMTFieldBuffer.Type);
                END;
                C.AppendLine(STRSUBSTNO('        field(%1; "%2"; %3)', DMTFieldBuffer."No.", DMTFieldBuffer.FieldName, _FieldTypeText));
                // field(1; "No."; Code[20])
                C.AppendLine('        {');
                C.AppendLine(STRSUBSTNO('            CaptionML = ENU = ''%1'', DEU = ''%2'';', DMTFieldBuffer.FieldName, DMTFieldBuffer."Field Caption"));

                IF DMTFieldBuffer.Type = DMTFieldBuffer.Type::Option THEN BEGIN
                    C.AppendLine('            OptionMembers = ' + DMTFieldBuffer.OPTIONSTRING + ';');
                    C.AppendLine(STRSUBSTNO('            OptionCaptionML = ENU = ''%1'', DEU = ''%2'';', DelChr(DMTFieldBuffer.OPTIONSTRING, '=', '"'), DelChr(DMTFieldBuffer.OPTIONCAPTION, '=', '"')));
                END;

                C.AppendLine('        }');

            UNTIL DMTFieldBuffer.NEXT() = 0;
        C.AppendLine('  }');
        C.AppendLine('    keys');
        C.AppendLine('    {');
        C.AppendLine('        key(Key1; ' + BuildKeyFieldsString(DMTTable."Old Version Table ID") + ')');
        C.AppendLine('        {');
        C.AppendLine('            Clustered = true;');
        C.AppendLine('        }');
        C.AppendLine('    }');
        C.AppendLine('');
        C.AppendLine('    fieldgroups');
        C.AppendLine('    {');
        C.AppendLine('    }');
        C.AppendLine('}');
    end;

    procedure DownloadFile(Content: TextBuilder; toFileName: text)
    var
        tempBlob: Codeunit "Temp Blob";
        iStr: InStream;
        allFilesTok: Label 'All Files (*.*)|*.*';
        oStr: OutStream;
    begin
        tempBlob.CreateOutStream(oStr);
        oStr.WriteText(Content.ToText());
        tempBlob.CreateInStream(iStr);
        DownloadFromStream(iStr, 'Download', 'ToFolder', allFilesTok, toFileName);
    end;

    procedure DownloadFileUTF8(Content: Text; toFileName: text)
    var
        tempBlob: Codeunit "Temp Blob";
        iStr: InStream;
        allFilesTok: Label 'All Files (*.*)|*.*';
        oStr: OutStream;
        DefaultEncoding: TextEncoding;
    begin
        DefaultEncoding := TextEncoding::Windows;
        tempBlob.CreateOutStream(oStr, DefaultEncoding);
        oStr.WriteText(Content);
        tempBlob.CreateInStream(iStr, DefaultEncoding);
        DownloadFromStream(iStr, 'Download', 'ToFolder', allFilesTok, toFileName);
    end;

    local procedure GetCleanFieldName(VAR Field: Record DMTFieldBuffer) CleanFieldName: Text
    begin
        CleanFieldName := DelChr(Field.FieldName, '=', '&-%/\(),. ');
    end;

    local procedure GetCleanTableName(Field: Record DMTFieldBuffer) CleanFieldName: Text
    begin
        CleanFieldName := ConvertStr(Field.TableName, '&-%/\(),. ', '__________');
    end;

    procedure FilterFields(VAR DMTFieldBuffer_FOUND: Record DMTFieldBuffer; TableNo: Integer; IncludeDisabled: Boolean; IncludeFlowFields: Boolean; IncludeBlob: Boolean) HasFields: Boolean
    var
        Debug: Integer;
    begin
        //* FilterField({TableNo}False{IncludeEnabled},False{IncludeFlowFields},False{IncludeBlob});
        CLEAR(DMTFieldBuffer_FOUND);
        DMTFieldBuffer_FOUND.SETRANGE(TableNo, TableNo);
        Debug := DMTFieldBuffer_FOUND.Count;
        IF NOT IncludeDisabled THEN
            DMTFieldBuffer_FOUND.SETRANGE(Enabled, TRUE);
        Debug := DMTFieldBuffer_FOUND.Count;
        DMTFieldBuffer_FOUND.SetFilter(Class, '%1|%2', DMTFieldBuffer_FOUND.Class::Normal, DMTFieldBuffer_FOUND.Class::FlowField);
        IF NOT IncludeFlowFields THEN
            DMTFieldBuffer_FOUND.SETRANGE(Class, DMTFieldBuffer_FOUND.Class::Normal);
        IF NOT IncludeBlob THEN
            DMTFieldBuffer_FOUND.SETFILTER(Type, '<>%1', DMTFieldBuffer_FOUND.Type::BLOB);
        // Fields_Found.Setrange(FieldName, 'Picture');
        // if Fields_Found.FindFirst() then;
        Debug := DMTFieldBuffer_FOUND.Count;
        DMTFieldBuffer_FOUND.Setrange(FieldName);
        HasFields := DMTFieldBuffer_FOUND.FindFirst();
    end;

    local procedure BuildKeyFieldsString(TableIDInNAV: Integer) KeyString: Text
    var
        dAMFieldBuffer: Record DMTFieldBuffer;
    begin
        dAMFieldBuffer.SetRange(TableNo, TableIDInNAV);
        dAMFieldBuffer.FindFirst();
        dAMFieldBuffer.SetFilter("No.", ConvertStr(dAMFieldBuffer."Primary Key", ',', '|'));
        dAMFieldBuffer.FindSet();
        repeat
            if ContainsLettersOnly(dAMFieldBuffer.FieldName) then
                KeyString += dAMFieldBuffer.FieldName + ','
            else
                KeyString += '"' + dAMFieldBuffer.FieldName + '",';
        until dAMFieldBuffer.Next() = 0;
        KeyString := DelChr(KeyString, '>', ',');
    end;

    local procedure ContainsLettersOnly(String: text): Boolean
    var
        LettersTok: Label 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', Locked = true;
    begin
        EXIT(DELCHR(String, '=', LettersTok) = '');
    end;
}
