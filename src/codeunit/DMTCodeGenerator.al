codeunit 110004 "DMTCodeGenerator"
{

    procedure CreateALXMLPort(DataFile: Record DMTDataFile) C: TextBuilder
    begin
        DataFile.Testfield("Import XMLPort ID");
        DataFile.Testfield("NAV Src.Table No.");
        DataFile.TestField("NAV Src.Table Caption");
        C := CreateALXMLPort(DataFile."Import XMLPort ID", DataFile."NAV Src.Table No.", DataFile."NAV Src.Table Caption");
    end;

    local procedure CreateALXMLPort(ImportXMLPortID: Integer; NAVSrcTableNo: Integer; NAVSrcTableCaption: Text) C: TextBuilder
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        DMTSetup: Record DMTSetup;
    begin
        C.AppendLine('xmlport ' + format(ImportXMLPortID) + ' T' + format(NAVSrcTableNo) + 'Import');
        C.AppendLine('{');
        DMTSetup.Get();
        if DMTSetup."Import with FlowFields" then
            C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + 'FlowField' + ''', ENU = ''' + DMTFieldBuffer.TableName + '(DMT)' + ''';')
        else
            C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + ''', ENU = ''' + DMTFieldBuffer.TableName + '(DMT)' + ''';');
        C.AppendLine('    Direction = Import;');
        C.AppendLine('    FieldSeparator = ''<TAB>'';');
        C.AppendLine('    FieldDelimiter = ''<None>'';');
        C.AppendLine('    TextEncoding = UTF8;');
        C.AppendLine('    Format = VariableText;');
        C.AppendLine('    FormatEvaluate = Xml;');
        C.AppendLine('');
        C.AppendLine('    schema');
        C.AppendLine('    {');
        C.AppendLine('        textelement(Root)');
        C.AppendLine('        {');

        IF FilterFields(DMTFieldBuffer, NAVSrcTableNo, FALSE, DMTSetup."Import with FlowFields", FALSE) then begin
            C.AppendLine('            tableelement(' + GetCleanTableName(DMTFieldBuffer) + '; ' + STRSUBSTNO('T%1Buffer', NAVSrcTableNo) + ')');
            C.AppendLine('            {');
            C.AppendLine('                XmlName = ''' + GetCleanTableName(DMTFieldBuffer) + ''';');
            DMTFieldBuffer.FINDSET();
            repeat
                C.AppendLine('                fieldelement("' + GetCleanFieldName(DMTFieldBuffer) + '"; ' + GetCleanTableName(DMTFieldBuffer) + '."' + DMTFieldBuffer.FieldName + '") { FieldValidate = No; MinOccurs = Zero; }');
            UNTIL DMTFieldBuffer.NEXT() = 0;
        end;

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
        C.AppendLine('                    Caption = ''Environment'',locked=true;');
        C.AppendLine('                    field(DatabaseName; GetDatabaseName()) { Caption = ''Database'',locked=true; ApplicationArea = all; }');
        C.AppendLine('                    field(COMPANYNAME; COMPANYNAME) { Caption = ''Company'',locked=true; ApplicationArea = all; }');
        C.AppendLine('                }');
        C.AppendLine('            }');
        C.AppendLine('        }');
        C.AppendLine('    }');
        C.AppendLine('');
        C.AppendLine('    trigger OnPostXmlPort()');
        C.AppendLine('    var');
        C.AppendLine('        ' + STRSUBSTNO('T%1Buffer', NAVSrcTableNo) + ': Record ' + STRSUBSTNO('T%1Buffer', NAVSrcTableNo) + ';');
        C.AppendLine('        LinesProcessedMsg: Label ''%1 Buffer\%2 lines imported'',locked=true;');
        C.AppendLine('    begin');
        C.AppendLine('        IF currXMLport.Filename <> '''' then //only for manual excecution');
        C.AppendLine('            MESSAGE(LinesProcessedMsg, ' + STRSUBSTNO('T%1Buffer', NAVSrcTableNo) + '.TABLECAPTION, ReceivedLinesCount);');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    trigger OnPreXmlPort()');
        C.AppendLine('    var');
        C.AppendLine('        ' + STRSUBSTNO('T%1Buffer', NAVSrcTableNo) + ': Record ' + STRSUBSTNO('T%1Buffer', NAVSrcTableNo) + ';');
        C.AppendLine('    begin');
        C.AppendLine('        ClearBufferBeforeImportTable(' + STRSUBSTNO('T%1Buffer', NAVSrcTableNo) + '.RECORDID.TABLENO);');
        C.AppendLine('        FileHasHeader := true;');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    var');
        C.AppendLine('        ReceivedLinesCount: Integer;');
        C.AppendLine('        FileHasHeader: Boolean;');
        C.AppendLine('');
        // C.AppendLine('    procedure GetFieldCaption(_TableNo: Integer;');
        // C.AppendLine('    _FieldNo: Integer) _FieldCpt: Text[1024]');
        // C.AppendLine('    var');
        // C.AppendLine('        _Field: Record "Field";');
        // C.AppendLine('    begin');
        // C.AppendLine('        IF _TableNo = 0 then exit('''');');
        // C.AppendLine('        IF _FieldNo = 0 then exit('''');');
        // C.AppendLine('        IF NOT _Field.GET(_TableNo, _FieldNo) then exit('''');');
        // C.AppendLine('        _FieldCpt := _Field."Field Caption";');
        // C.AppendLine('    end;');
        // C.AppendLine('');
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
        C.AppendLine('        ActiveSession.SetRange("Server Instance ID", SERVICEINSTANCEID());');
        C.AppendLine('        ActiveSession.SetRange("Session ID", SESSIONID());');
        C.AppendLine('        ActiveSession.findfirst();');
        C.AppendLine('        exit(ActiveSession."Database Name");');
        C.AppendLine('    end;');
        C.AppendLine('}');
    end;

    procedure CreateALTable(DataFile: Record DMTDataFile) C: TextBuilder
    begin
        DataFile.testfield("Buffer Table ID");
        DataFile.TestField("NAV Src.Table No.");
        DataFile.TestField("NAV Src.Table Caption");
        C := CreateALTable(DataFile."Target Table ID", DataFile."Buffer Table ID", DataFile."NAV Src.Table No.", DataFile."NAV Src.Table Caption");
    end;

    local procedure CreateALTable(TargetTableID: Integer; BufferTableID: Integer; NAVSrcTableNo: Integer; NAVSrcTableCaption: Text) C: TextBuilder
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        DMTSetup: Record DMTSetup;
        _FieldTypeText: Text;
    begin
        DMTSetup.Get();
        FilterFields(DMTFieldBuffer, NAVSrcTableNo, FALSE, true, FALSE);
        C.AppendLine('table ' + FORMAT(BufferTableID) + ' ' + STRSUBSTNO('T%1Buffer', NAVSrcTableNo));
        C.AppendLine('{');
        C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + ''', ENU = ''' + DMTFieldBuffer.TableName + '(DMT)' + ''';');
        C.AppendLine('  fields {');
        if FilterFields(DMTFieldBuffer, NAVSrcTableNo, FALSE, DMTSetup."Import with FlowFields", FALSE) then
            repeat
                CASE DMTFieldBuffer.Type OF
                    DMTFieldBuffer.Type::RecordID:
                        _FieldTypeText := 'Text[250]'; // Import recordIDs as text to avoid validation issues on import
                    DMTFieldBuffer.Type::Code, DMTFieldBuffer.Type::Text:
                        _FieldTypeText := STRSUBSTNO('%1[%2]', DMTFieldBuffer.Type, DMTFieldBuffer.Len);
                    ELSE
                        _FieldTypeText := FORMAT(DMTFieldBuffer.Type);
                end;
                C.AppendLine(STRSUBSTNO('        field(%1; "%2"; %3)', DMTFieldBuffer."No.", DMTFieldBuffer.FieldName, _FieldTypeText));
                // field(1; "No."; Code[20])
                C.AppendLine('        {');
                C.AppendLine(STRSUBSTNO('            CaptionML = ENU = ''%1'', DEU = ''%2'';', DMTFieldBuffer.FieldName, DMTFieldBuffer."Field Caption"));

                IF DMTFieldBuffer.Type = DMTFieldBuffer.Type::Option then begin
                    C.AppendLine('            OptionMembers = ' + DMTFieldBuffer.OPTIONSTRING + ';');
                    C.AppendLine(STRSUBSTNO('            OptionCaptionML = ENU = ''%1'', DEU = ''%2'';', DelChr(DMTFieldBuffer.OPTIONSTRING, '=', '"'), DelChr(DMTFieldBuffer.OPTIONCAPTION, '=', '"')));
                end;

                C.AppendLine('        }');

            UNTIL DMTFieldBuffer.NEXT() = 0;
        AddTargetRecordExistsFlowField(TargetTableID, BufferTableID, DMTFieldBuffer, C);
        C.AppendLine('  }');
        C.AppendLine('    keys');
        C.AppendLine('    {');
        C.AppendLine('        key(Key1; ' + BuildKeyFieldsString(NAVSrcTableNo) + ')');
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
        oStr: OutStream;
    begin
        tempBlob.CreateOutStream(oStr, TextEncoding::UTF8);  // Import / Export as UTF-8
        oStr.WriteText(Content.ToText());
        tempBlob.CreateInStream(iStr);
        toFileName := DelChr(toFileName, '=', '#&-%/\(), ');
        DownloadFromStream(iStr, 'Download', 'ToFolder', Format(Enum::DMTFileFilter::All), toFileName);
    end;

    local procedure GetCleanFieldName(VAR Field: Record DMTFieldBuffer) CleanFieldName: Text
    begin
        CleanFieldName := DelChr(Field.FieldName, '=', '#&-%/\(),. ');
        // XMLPort Fieldelements cannot start with numbers
        if CleanFieldName <> '' then
            if CopyStr(CleanFieldName, 1, 1) IN ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'] then
                CleanFieldName := '_' + CleanFieldName;
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
        DMTFieldBuffer_FOUND.SetRange(TableNo, TableNo);
        Debug := DMTFieldBuffer_FOUND.Count;
        IF NOT IncludeDisabled then
            DMTFieldBuffer_FOUND.SetRange(Enabled, TRUE);
        Debug := DMTFieldBuffer_FOUND.Count;
        DMTFieldBuffer_FOUND.SetFilter(Class, '%1|%2', DMTFieldBuffer_FOUND.Class::Normal, DMTFieldBuffer_FOUND.Class::FlowField);
        IF NOT IncludeFlowFields then
            DMTFieldBuffer_FOUND.SetRange(Class, DMTFieldBuffer_FOUND.Class::Normal);
        IF NOT IncludeBlob then
            DMTFieldBuffer_FOUND.SETFILTER(Type, '<>%1', DMTFieldBuffer_FOUND.Type::BLOB);
        // Fields_Found.SetRange(FieldName, 'Picture');
        // if Fields_Found.FindFirst() then;
        Debug := DMTFieldBuffer_FOUND.Count;
        DMTFieldBuffer_FOUND.SetRange(FieldName);
        HasFields := DMTFieldBuffer_FOUND.FindFirst();
    end;

    local procedure BuildKeyFieldsString(TableIDInNAV: Integer) KeyString: Text
    var
        FieldBuffer: Record DMTFieldBuffer;
        FieldID: Integer;
        FieldIds: List of [Text];
        FieldIDText: Text;
        OrderedKeyFieldNos: Text;
    begin
        FieldBuffer.SetRange(TableNo, TableIDInNAV);
        FieldBuffer.FindFirst();
        OrderedKeyFieldNos := FieldBuffer."Primary Key";
        if OrderedKeyFieldNos.Contains(',') then begin
            FieldIds := OrderedKeyFieldNos.Split(',');
        end else begin
            FieldIds.Add(OrderedKeyFieldNos);
        end;

        foreach FieldIDText in FieldIds do begin
            Evaluate(FieldID, FieldIDText);
            FieldBuffer.get(TableIDInNAV, FieldID);
            KeyString += GetALFieldNameWithMasking(FieldBuffer.FieldName) + ',';
        end;
        KeyString := DelChr(KeyString, '>', ',');
    end;

    local procedure AddTargetRecordExistsFlowField(TargetTableID: Integer; BufferTableNo: Integer; var DMTFieldBuffer: Record DMTFieldBuffer; var C: TextBuilder)
    var
        DMTMgt: Codeunit DMTMgt;
        BufferRef, TargetRef : RecordRef;
        TargetTableName: text;
        BufferKeyFieldNames, TargetKeyFieldNames : List of [Text];
        KeyFieldIndex: Integer;
        f: TextBuilder;
    begin
        if DMTFieldBuffer.Get(BufferTableNo, 59999) then
            exit;
        TargetRef.Open(TargetTableID);
        TargetTableName := QuoteValue(TargetRef.Name);
        BufferRef.Open(BufferTableNo);
        for KeyFieldIndex := 1 to DMTMgt.GetListOfKeyFieldIDs(TargetRef).Count do
            TargetKeyFieldNames.Add(QuoteValue(TargetRef.KeyIndex(1).FieldIndex(KeyFieldIndex).Name));
        for KeyFieldIndex := 1 to DMTMgt.GetListOfKeyFieldIDs(BufferRef).Count do
            BufferKeyFieldNames.Add(QuoteValue(BufferRef.KeyIndex(1).FieldIndex(KeyFieldIndex).Name));
        if TargetKeyFieldNames.Count <> BufferKeyFieldNames.Count then
            exit;

        f.AppendLine('        field(59999; "DMT Target Record Exists"; Boolean)');
        f.AppendLine('        {');
        f.AppendLine('            CaptionML = ENU = ''DMT target record exists'', DEU = ''DMT Zieldatensatz vorhanden'';');
        f.AppendLine('            FieldClass = FlowField;');

        for KeyFieldIndex := 1 to TargetKeyFieldNames.Count do begin
            if KeyFieldIndex = 1 then
                f.Append('            CalcFormula = exist(' + TargetTableName + ' where(' + TargetKeyFieldNames.Get(KeyFieldIndex) + '= field(' + BufferKeyFieldNames.Get(KeyFieldIndex) + ')')
            else begin
                f.AppendLine('');
                f.Append('                                                     ' + TargetKeyFieldNames.Get(KeyFieldIndex) + '= field(' + BufferKeyFieldNames.Get(KeyFieldIndex) + ')');
            end;
            if KeyFieldIndex = TargetKeyFieldNames.Count then
                f.AppendLine('));')
            else
                f.Append(',')
        end;

        f.AppendLine('            Editable = false;');
        f.AppendLine('        }');
        c.Append(f.ToText());
    end;

    local procedure QuoteValue(TextValue: Text): Text
    var
        DummyText: Text;
        Letters: Label 'abcdefghijklmnopqrstuvwxyz';
        numbers: Label '0123456789';
        i: Integer;
    begin
        DummyText := DelChr(TextValue.ToLower(), '=', Letters);
        DummyText := DelChr(DummyText, '=', numbers);
        if DummyText <> '' then
            exit('"' + TextValue + '"')
        else
            exit(TextValue);
    end;

    procedure GetALFieldNameWithMasking(FieldName: Text) MaskedFieldName: Text
    var
        LettersTok: Label 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', Locked = true;
    begin
        if DelChr(FieldName, '=', LettersTok) = '' then
            MaskedFieldName := FieldName
        else
            MaskedFieldName := '"' + FieldName + '"';
    end;
}
