codeunit 91003 DAMObjectGenerator
{
    procedure GetNavClassicDataport(ObjectID: Integer) Content: text;
    var
        DAMExportObject: Record DAMExportObject;
        DAMSetup: Record "DAM Setup";
        BigTextContent: BigText;
        IStr: instream;
    begin
        DAMExportObject.get();
        DAMSetup.Get();
        DAMSetup.TestField("Object ID Export Object");
        DAMExportObject.CalcFields(ExportDataPort);
        DAMExportObject.ExportDataPort.CreateInStream(IStr);
        BigTextContent.Read(IStr);
        BigTextContent.GetSubText(Content, 1);
        Content := Content.Replace('OBJECT Dataport 50004 DAMExport',
                                   'OBJECT Dataport ' + Format(DAMSetup."Object ID Export Object") + ' DAMExport')
    end;

    procedure GetNAVRTCXMLPort(ObjectID: Integer) Content: text;
    var
        DAMExportObject: Record "DAMExportObject";
        DAMSetup: Record "DAM Setup";
        BigTextContent: BigText;
        IStr: instream;
    begin
        DAMExportObject.Get();
        DAMSetup.get();
        DAMSetup.TestField("Object ID Export Object");
        DAMExportObject.CalcFields(ExportXMLPort);
        DAMExportObject.ExportDataPort.CreateInStream(IStr);
        BigTextContent.Read(IStr);
        BigTextContent.GetSubText(Content, 1);

        Content := Content.Replace('OBJECT XMLport 50022 DAM Export',
                                   'OBJECT XMLport ' + Format(DAMSetup."Object ID Export Object") + ' DAM Export');
        Content := Content.Replace('damExport@1000000002 : XMLport 50022;',
                                   'damExport@1000000002 : XMLport ' + Format(DAMSetup."Object ID Export Object") + ';')
    end;

    procedure CreateALXMLPort(DAMTable: Record DAMTable) C: TextBuilder
    var
        DAMFieldBuffer: Record DAMFieldBuffer;
    begin
        DAMTable.Testfield("Import XMLPort ID");
        DAMTable.Testfield("Old Version Table ID");

        C.AppendLine('xmlport ' + format(DAMTable."Import XMLPort ID") + ' T' + format(DAMTable."Old Version Table ID") + 'Import');
        C.AppendLine('{');
        C.AppendLine('    Caption = ''' + DAMTable."Old Version Table Caption" + ''';');
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

        IF FilterFields(DAMFieldBuffer, DAMTable."Old Version Table ID", FALSE, FALSE, FALSE) THEN BEGIN
            C.AppendLine('            tableelement(' + GetCleanTableName(DAMFieldBuffer) + '; ' + STRSUBSTNO('T%1Buffer', DAMTable."Old Version Table ID") + ')');
            C.AppendLine('            {');
            C.AppendLine('                XmlName = ''' + GetCleanTableName(DAMFieldBuffer) + ''';');
            DAMFieldBuffer.FINDSET();
            REPEAT
                C.AppendLine('                fieldelement("' + GetCleanFieldName(DAMFieldBuffer) + '"; ' + GetCleanTableName(DAMFieldBuffer) + '."' + DAMFieldBuffer.FieldName + '") { FieldValidate = No; MinOccurs = Zero; }');
            UNTIL DAMFieldBuffer.NEXT() = 0;
        END;

        C.AppendLine('                trigger OnBeforeInsertRecord()');
        C.AppendLine('                begin');
        C.AppendLine('                    ReceivedLinesCount += 1;');
        C.AppendLine('');
        C.AppendLine('                    //SKIP HEADER LINES');
        C.AppendLine('                    IF ReceivedLinesCount <= StartFromLine then');
        C.AppendLine('                        currXMLport.SKIP();');
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
        C.AppendLine('    begin');
        C.AppendLine('        IF currXMLport.FILENAME <> '''' then //only for manual excecution');
        C.AppendLine('            MESSAGE(LinesProcessedMsg, ' + GetCleanTableName(DAMFieldBuffer) + '.TABLECAPTION, ReceivedLinesCount);');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    trigger OnPreXmlPort()');
        C.AppendLine('    begin');
        C.AppendLine('        ClearBufferBeforeImportTable(' + GetCleanTableName(DAMFieldBuffer) + '.RECORDID.TABLENO);');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    var');
        C.AppendLine('        ReceivedLinesCount: Integer;');
        C.AppendLine('        StartFromLine: Integer;');
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

    procedure CreateALTable(DAMTable: Record DAMTable) C: TextBuilder
    var
        DAMFieldBuffer: Record DAMFieldBuffer;
        _FieldTypeText: Text;
    begin
        DAMTable.testfield("Buffer Table ID");
        DAMTable.TestField("Old Version Table ID");
        FilterFields(DAMFieldBuffer, DAMTable."Old Version Table ID", FALSE, FALSE, FALSE);
        C.AppendLine('table ' + FORMAT(DAMTable."Buffer Table ID") + ' ' + STRSUBSTNO('T%1Buffer', DAMTable."Old Version Table ID"));
        C.AppendLine('{');
        C.AppendLine('    CaptionML= DEU = ''' + DAMTable."Old Version Table Caption" + '(DAM)' + ''', ENU = ''' + DAMFieldBuffer.TableName + '(DAM)' + ''';');
        C.AppendLine('  fields {');
        IF FilterFields(DAMFieldBuffer, DAMTable."Old Version Table ID", FALSE, FALSE, FALSE) THEN
            REPEAT
                CASE DAMFieldBuffer.Type OF
                    DAMFieldBuffer.Type::Code, DAMFieldBuffer.Type::Text:
                        _FieldTypeText := STRSUBSTNO('%1[%2]', DAMFieldBuffer.Type, DAMFieldBuffer.Len);
                    ELSE
                        _FieldTypeText := FORMAT(DAMFieldBuffer.Type);
                END;
                C.AppendLine(STRSUBSTNO('        field(%1; "%2"; %3)', DAMFieldBuffer."No.", DAMFieldBuffer.FieldName, _FieldTypeText));
                // field(1; "No."; Code[20])
                C.AppendLine('        {');
                C.AppendLine(STRSUBSTNO('            CaptionML = ENU = ''%1'', DEU = ''%2'';', DAMFieldBuffer.FieldName, DAMFieldBuffer."Field Caption"));

                IF DAMFieldBuffer.Type = DAMFieldBuffer.Type::Option THEN BEGIN
                    C.AppendLine('            OptionMembers = ' + DAMFieldBuffer.OPTIONSTRING + ';');
                    C.AppendLine(STRSUBSTNO('            OptionCaptionML = ENU = ''%1'', DEU = ''%2'';', DelChr(DAMFieldBuffer.OPTIONSTRING, '=', '"'), DelChr(DAMFieldBuffer.OPTIONCAPTION, '=', '"')));
                END;

                C.AppendLine('        }');

            UNTIL DAMFieldBuffer.NEXT() = 0;
        C.AppendLine('  }');
        C.AppendLine('    keys');
        C.AppendLine('    {');
        C.AppendLine('        key(Key1; ' + BuildKeyString(DAMTable."Old Version Table ID") + ')');
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

    local procedure GetCleanFieldName(VAR Field: Record DAMFieldBuffer) CleanFieldName: Text
    begin
        CleanFieldName := DelChr(Field.FieldName, '=', '&-%/\(),. ');
    end;

    local procedure GetCleanTableName(Field: Record DAMFieldBuffer) CleanFieldName: Text
    begin
        CleanFieldName := ConvertStr(Field.TableName, '&-%/\(),. ', '__________');
    end;

    local procedure FilterFields(VAR Fields_Found: Record DAMFieldBuffer; TableNo: Integer; IncludeDisabled: Boolean; IncludeFlowFields: Boolean; IncludeBlob: Boolean) HasFields: Boolean
    var
        Debug: Integer;
    begin
        //* FilterField({TableNo}False{IncludeEnabled},False{IncludeFlowFields},False{IncludeBlob});
        CLEAR(Fields_Found);
        Fields_Found.SETRANGE(TableNo, TableNo);
        Debug := Fields_Found.Count;
        IF NOT IncludeDisabled THEN
            Fields_Found.SETRANGE(Enabled, TRUE);
        Debug := Fields_Found.Count;
        // AUSNAHME FÜR TABELLE 54296, hier alle FlowFields als echte Felder übernehmen
        IF TableNo <> 54296 THEN
            IF NOT IncludeFlowFields THEN
                Fields_Found.SETRANGE(Class, Fields_Found.Class::Normal);
        IF NOT IncludeBlob THEN
            Fields_Found.SETFILTER(Type, '<>%1', Fields_Found.Type::BLOB);
        // Fields_Found.Setrange(FieldName, 'Picture');
        // if Fields_Found.FindFirst() then;
        Debug := Fields_Found.Count;
        Fields_Found.Setrange(FieldName);
        HasFields := Fields_Found.FindFirst();
    end;

    local procedure BuildKeyString(TableIDInNAV: Integer) KeyString: Text
    var
        dAMFieldBuffer: Record DAMFieldBuffer;
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
