codeunit 91005 XMLBackup
{

    procedure Export();
    begin
        MarkAll();
        ExportXML();
    end;

    procedure Import();
    var
        DAMSetup: Record "DAM Setup";
        TargetRef: RecordRef;
        FldRef: FieldRef;
        serverFile: file;
        InStr: InStream;
        FieldNodeID: Integer;
        TableNodeID: Integer;
        FileName: Text;
        XFieldNode: XmlNode;
        XRecordNode: XmlNode;
        XTableNode: XmlNode;
        XFieldList: XmlNodeList;
        XRecordList: XmlNodeList;
        XTableList: XmlNodeList;
        FileFound: Boolean;
        Start: DateTime;
    begin
        if DAMSetup.Get() and (DAMSetup."Backup.xml File Path" <> '') then
            if ServerFile.Open(DAMSetup."Backup.xml File Path") then begin
                FileFound := true;
                ServerFile.CreateInStream(InStr);
            end;

        if not FileFound then
            if not UploadIntoStream('Select a Backup.XML file', '', 'XML Files|*.xml', FileName, InStr) then begin
                exit;
            end;

        Start := CurrentDateTime;
        Clear(XDoc);
        if not XmlDocument.ReadFrom(InStr, XDoc) then
            Error('reading xml failed');
        XDoc.SelectNodes('//DAM/child::*', XTableList);
        foreach XTableNode in XTableList do begin
            Evaluate(TableNodeID, GetAttributeValue(XTableNode, 'ID'));
            XTableNode.SelectNodes('child::RECORD', XRecordList); // select all element children
            foreach XRecordNode in XRecordList do begin
                Clear(TargetRef);
                TargetRef.Open(TableNodeID, false);
                //XFieldList := XRecordNode.AsXmlElement().GetChildNodes();
                XRecordNode.SelectNodes('child::*', XFieldList); // select all element children
                foreach XFieldNode in XFieldList do begin
                    Evaluate(FieldNodeID, GetAttributeValue(XFieldNode, 'ID'));
                    if TargetRef.FieldExist(FieldNodeID) then begin
                        FldRef := TargetRef.Field(FieldNodeID);
                        if XFieldNode.AsXmlElement().InnerText <> '' then
                            FldRefEvaluate(FldRef, XFieldNode.AsXmlElement().InnerText);
                    end;
                end;
                if not TargetRef.modify() then TargetRef.insert();
            end;
        end;

        Message('Import abgeschlossen\ Import Dauer: %1', CurrentDateTime - Start);
    end;

    procedure AddAttribute(XNode: XmlNode; AttrName: Text; AttrValue: Text): Boolean
    begin
        if not XNode.IsXmlElement then
            exit(false);
        XNode.AsXmlElement().SetAttribute(AttrName, AttrValue);
    end;

    procedure GetAttributeValue(XNode: XmlNode; AttrName: Text): Text
    var
        XAttribute: XmlAttribute;
    begin
        if XNode.AsXmlElement().Attributes().Get(AttrName, XAttribute) then
            exit(XAttribute.Value());
    end;

    local procedure ExportXML();
    VAR
        allObj: Record AllObj;
        tempTenantMedia: Record "Tenant Media" temporary;
        tableID: Integer;
        oStr: OutStream;
        rootNode: XMLNode;
        tableNode: XMLNode;
        fieldDefinitionNode: XmlNode;
    begin
        // DOKUMENT
        Clear(XDoc);
        XDoc := XmlDocument.Create();

        // ROOT
        rootNode := XmlElement.Create('DAM').AsXmlNode();
        XDoc.Add(rootNode);
        AddAttribute(rootNode, 'Version', '1.1');

        // Table Loop
        CreateTableIDList(TablesList);
        foreach tableID in Tableslist do
            IF GetTableLineCount(tableID) > 0 then begin
                allObj.GET(allObj."Object Type"::Table, tableID);
                tableNode := XmlElement.Create(CreateTagName(allObj."Object Name")).AsXmlNode();
                rootNode.AsXmlElement().Add(tableNode);

                AddAttribute(tableNode, 'ID', Format(tableID));
                fieldDefinitionNode := CreateFieldDefinitionNode(tableID);
                tableNode.AsXmlElement().Add(fieldDefinitionNode);
                AddTable(tableNode, allObj."Object ID");
            end;

        tempTenantMedia.Content.CreateOutStream(oStr);
        XDoc.WriteTo(oStr);

        DownloadBlobContent(tempTenantMedia, FORMAT(CURRENTDATETIME, 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2>_<Seconds,2>') + '_Backup.xml', TextEncoding::UTF8);

        //RESET;
        Clear(TablesList);
        Clear(RecordIDList);
    end;

    procedure GetTableLineCount(_TableID: Integer) _LineCount: Integer;
    var
        ID: RecordId;
    begin
        foreach ID in RecordIDList do
            if _TableID = ID.TableNo then
                _LineCount += 1;
    end;

    local procedure AddTable(VAR _XMLNode_Start: XMLNode; i_TableID: Integer);
    VAR
        tempTenantMedia: Record "Tenant Media" temporary;
        ID: RecordId;
        recRef: RecordRef;
        fldRef: FieldRef;
        booleanType: Boolean;
        i: Integer;
        fieldNode: XMLNode;
        recordNode: XMLNode;
        textNode: XmlText;
        fieldIDsList: List of [Integer];
        keyFieldID: Integer;
        fieldValueAsText: Text;
    begin
        foreach ID in RecordIDList do begin
            if ID.TableNo = i_TableID then begin
                recordNode := XmlElement.Create('RECORD').AsXmlNode();
                _XMLNode_Start.AsXmlElement().Add(recordNode);
                recRef.Get(ID);
                GetListOfKeyFieldIDs(recRef, fieldIDsList);
                // Add Key Fields As Attributes
                foreach keyFieldID in fieldIDsList do begin
                    fldRef := recRef.FIELD(keyFieldID);
                    AddAttribute(recordNode, CreateTagName(fldRef.NAME), GetFldRefValueAsText(fldRef));
                end;
                // Add Fields with Value
                for i := 1 TO recRef.FIELDCOUNT do begin
                    fldRef := recRef.FIELDINDEX(i);
                    if not FldRefIsEmpty(fldRef) then begin
                        fieldNode := XmlElement.Create('FIELD').AsXmlNode();
                        recordNode.AsXmlElement().Add(fieldNode);
                        AddAttribute(fieldNode, 'ID', Format(fldRef.NUMBER));
                        fieldValueAsText := GetFldRefValueAsText(fldRef);
                        textNode := XmlText.Create(fieldValueAsText);
                        fieldNode.AsXmlElement().Add(textNode);
                    end;
                end;
            end;
        end;
    end;

    procedure FldRefIsEmpty(FldRef: FieldRef) IsEmpty: Boolean
    var
        booleanType: Boolean;
        guidType: Guid;
        fieldTypeText: Text;
        dateType: Date;
        timeType: Time;
        integerType: Integer;
        durationtype: Duration;
        InitRef: RecordRef;
    begin
        InitRef.Open(FldRef.Record().Number);
        InitRef.Init();
        IsEmpty := (InitRef.Field(FldRef.Number).Value = FldRef.Value);
        exit(IsEmpty);
        fieldTypeText := Strsubstno('%1="%2"', Format(FldRef.Type), FldRef.Value);
        case FldRef.Type of
            FieldType::Boolean:
                begin
                    booleanType := FldRef.Value;
                    IsEmpty := (booleanType = false);
                end;
            FieldType::BigInteger, Fieldtype::Integer, Fieldtype::Decimal:
                IsEmpty := Format(FldRef.Value) = '0';
            Fieldtype::Time:
                begin
                    timeType := FldRef.Value;
                    IsEmpty := timeType = 0T;
                end;
            Fieldtype::Date:
                begin
                    dateType := FldRef.Value;
                    IsEmpty := dateType = 0D;
                end;
            Fieldtype::Text, Fieldtype::Code, Fieldtype::DateFormula, Fieldtype::DateTime, Fieldtype::RecordId:
                IsEmpty := Format(FldRef.Value) = '';
            FieldType::Guid:
                begin
                    guidType := FldRef.Value;
                    IsEmpty := IsNullGuid(guidType);
                end;
            Fieldtype::Blob:
                begin
                    FldRef.CalcField();
                    IsEmpty := (Format(FldRef.Value) = '0');
                end;
            Fieldtype::Media, Fieldtype::MediaSet:
                IsEmpty := IsNullGuid(Format(FldRef.Value));
            Fieldtype::Option:
                begin
                    integerType := FldRef.Value;
                    IsEmpty := integerType = 0;
                end;
            Fieldtype::Duration:
                begin
                    durationtype := FldRef.Value;
                    IsEmpty := durationtype = 0;
                end;

            else
                Error('IsEmptyFldRef: unhandled field type %1', FldRef.Type);
        end; // end_case
    end;

    procedure FldRefEvaluate(var FldRef: FieldRef; ValueAsText: Text)
    var
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        DateFormulaType: DateFormula;
        RecordIDType: RecordId;
        BigIntegerType: BigInteger;
        BooleanType: Boolean;
        DateType: Date;
        DateTimeType: DateTime;
        DecimalType: Decimal;
        DurationType: Duration;
        GUIDType: Guid;
        IntegerType: Integer;
        OStream: OutStream;
        TimeType: Time;
    begin
        case FldRef.TYPE OF
            FldRef.Type::BigInteger:
                begin
                    Evaluate(BigIntegerType, ValueAsText);
                    FldRef.Value(BigIntegerType);
                end;
            FldRef.Type::Blob:
                begin
                    Clear(TenantMedia.Content);
                    IF ValueAsText <> '' then begin
                        TenantMedia.Content.CreateOutStream(OStream);
                        Base64Convert.FromBase64(ValueAsText, OStream);
                    end;
                    FldRef.Value(TenantMedia.Content);
                end;
            FldRef.Type::Boolean:
                begin
                    Evaluate(BooleanType, ValueAsText, 9);
                    FldRef.Value(BooleanType);
                end;
            FldRef.Type::Text,
            FldRef.Type::Code:
                FldRef.Value(ValueAsText);
            FldRef.Type::Date:
                begin
                    Evaluate(DateType, ValueAsText, 9);
                    FldRef.Value(DateType);
                end;
            FldRef.Type::DateFormula:
                begin
                    Evaluate(DateFormulaType, ValueAsText, 9);
                    FldRef.Value(DateFormulaType);
                end;
            FldRef.Type::DateTime:
                begin
                    Evaluate(DateTimeType, ValueAsText, 9);
                    FldRef.Value(DateTimeType);
                end;
            FldRef.Type::Decimal:
                begin
                    Evaluate(DecimalType, ValueAsText, 9);
                    FldRef.Value(DecimalType);
                end;
            FldRef.Type::Duration:
                begin
                    Evaluate(DurationType, ValueAsText, 9);
                    FldRef.Value(DurationType);
                end;
            FldRef.Type::Guid:
                begin
                    Evaluate(GuidType, ValueAsText, 9);
                    FldRef.Value(GuidType);
                end;
            FldRef.Type::Integer,
            FldRef.Type::Option:
                begin
                    Evaluate(IntegerType, ValueAsText, 9);
                    FldRef.Value(IntegerType);
                end;
            //FldRef.Type::Media:
            //    ;
            //FldRef.Type::MediaSet:
            //    ;
            FldRef.Type::RecordId:
                begin
                    Evaluate(RecordIDType, ValueAsText, 9);
                    FldRef.Value(RecordIDType);
                end;
            FldRef.Type::Time:
                begin
                    Evaluate(TimeType, ValueAsText, 9);
                    FldRef.Value(TimeType);
                end;
            FldRef.Type::TableFilter:
                ;
            else
                Error('FldRefEvaluate: unhandled field type %1', FldRef.Type);
        end;

    end;

    procedure GetFldRefValueAsText(var FldRef: FieldRef) ValueText: Text;
    begin
        case Format(FldRef.Type) OF
            'BLOB':
                GetBlobFieldAsText(FldRef, true, ValueText);
            'Media':
                GetMediaFieldAsText(FldRef, true, ValueText);
            'MediaSet':
                Error('not Implemented');
            'BigInteger',
            'Boolean',
            'Code',
            'Date',
            'DateFormula',
            'DateTime',
            'Decimal',
            'Duration',
            'GUID',
            'Integer',
            'Option',
            'RecordId',
            'TableFilter',
            'Text',
            'Time',
            'RecordID':
                ValueText := FORMAT(FldRef.VALUE, 0, 9);
            else
                Error('GetFldRefValueAsText:unhandled Fieldtype %1', FldRef.Type);
        end;
    end;

    local procedure CreateListOfExportFields(var RecRef: RecordRef; var FieldIDs: List of [Dictionary of [Text, Text]])
    var
        FldRef: FieldRef;
        FieldProps: Dictionary of [Text, Text];
        FldIndex: Integer;
    begin
        for FldIndex := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(FldIndex);
            If (FldRef.Class = FldRef.Class::Normal) and FldRef.Active then begin
                Clear(FieldProps);
                FieldProps.Add('ID', Format(FldRef.Number));
                FieldProps.Add('Name', FldRef.Name);
                FieldIDs.Add(FieldProps);
            end;
        end;
    end;

    procedure CreateFieldDefinitionNode(tableID: Integer) XFieldDefinition: XmlNode
    var
        recRef: RecordRef;
        fldRef: FieldRef;
        fieldID: Dictionary of [Text, Text];
        ID: Integer;
        fieldIDs: List of [Dictionary of [Text, Text]];
        xField: XmlNode;
    begin
        recRef.Open(tableID);
        recRef.Init();
        XFieldDefinition := XmlElement.Create('FieldDefinition').AsXmlNode();
        CreateListOfExportFields(recRef, fieldIDs);
        foreach fieldID in fieldIDs do begin
            Clear(fldRef);
            Evaluate(ID, fieldID.Get('ID'));
            fldRef := recRef.Field(ID);
            xField := XmlElement.Create('Field').AsXmlNode();
            AddAttribute(xField, 'Number', format(fldRef.Number));
            AddAttribute(xField, 'Type', FORMAT(fldRef.TYPE));
            if fldRef.Length <> 0 then
                AddAttribute(xField, 'Length', FORMAT(fldRef.LENGTH));
            if fldRef.Class <> FieldClass::Normal then
                AddAttribute(xField, 'Class', FORMAT(fldRef.CLASS));
            if not fldRef.Active then
                AddAttribute(xField, 'Active', FORMAT(fldRef.Active, 0, 9));
            AddAttribute(xField, 'Name', FORMAT(fldRef.Name, 0, 9));
            AddAttribute(xField, 'Caption', FORMAT(fldRef.Caption, 0, 9));
            if not (fldRef.Type in [FieldType::Blob, FieldType::Media, FieldType::MediaSet]) then
                AddAttribute(xField, 'InitValue', Format(recRef.Field(fldRef.Number).Value, 0, 9));
            If fldRef.Type = FieldType::Option then begin
                AddAttribute(xField, 'OptionCaption', FORMAT(fldRef.OptionCaption));
                AddAttribute(xField, 'OptionMembers', FORMAT(fldRef.OptionMembers));
            end;
            if fldRef.Relation <> 0 then
                AddAttribute(xField, 'Relation', FORMAT(fldRef.Relation));
            XFieldDefinition.AsXmlElement().Add(xField);
        end;
    end;

    procedure CreateTableIDList(TablesList: List of [Integer]);
    var
        ID: RecordId;
    begin
        foreach ID in RecordIDList do
            if not TablesList.Contains(ID.TableNo) then
                TablesList.Add(ID.TableNo);
    end;

    procedure CreateTagName(_Name: Text) _TagName: Text;
    begin
        _Name := DELCHR(_Name, '=', ' ');
        _TagName := CONVERTSTR(_Name, '\/-.()', '______')
    end;

    procedure GetListOfKeyFieldIDs(VAR _RecRef: RecordRef; VAR KeyFieldIDsList: List of [Integer]);
    VAR
        _FieldRef: FieldRef;
        _KeyIndex: Integer;
        _KeyRef: KeyRef;
    begin
        Clear(KeyFieldIDsList);
        _KeyRef := _RecRef.KEYINDEX(1);
        for _KeyIndex := 1 TO _KeyRef.FIELDCOUNT do begin
            _FieldRef := _KeyRef.FIELDINDEX(_KeyIndex);
            KeyFieldIDsList.Add(_FieldRef.Number);
        end;
    end;

    procedure MarkAll();
    VAR
        _RecRef: RecordRef;
        TableID: Integer;
        TablesToExport: List of [Integer];
    begin
        TablesToExport.Add(Database::DAMTable);
        TablesToExport.Add(Database::DAMField);
        foreach TableID in TablesToExport do begin
            _RecRef.OPEN(TableID);
            if _RecRef.FINDSET(false, false) then
                repeat
                    if not RecordIDList.Contains(_RecRef.RecordId) then
                        RecordIDList.Add(_RecRef.RecordId);
                until _RecRef.Next() = 0;
            _RecRef.close();

        end;
    end;

    procedure DownloadBlobContent(var TempTenantMedia: Record "Tenant Media"; FileName: Text; FileEncoding: TextEncoding): Text
    var
        FileMgt: Codeunit "File Management";
        IsDownloaded: Boolean;
        InStr: InStream;
        Path: text;
        OutExt: text;
        AllFilesDescriptionTxt: TextConst DEU = 'Alle Dateien (*.*)|*.*', ENU = 'All Files (*.*)|*.*';
        ExcelFileTypeTok: TextConst DEU = 'Excel-Dateien (*.xlsx)|*.xlsx', ENU = 'Excel Files (*.xlsx)|*.xlsx';
        ExportLbl: TextConst DEU = 'Export', ENU = 'Export';
        RDLFileTypeTok: TextConst DEU = 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc', ENU = 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc';
        TXTFileTypeTok: TextConst DEU = 'Textdateien (*.txt)|*.txt', ENU = 'Text Files (*.txt)|*.txt';
        XMLFileTypeTok: TextConst DEU = 'XML-Dateien (*.xml)|*.xml', ENU = 'XML Files (*.xml)|*.xml';
        ZIPFileTypeTok: TextConst DEU = 'ZIP-Dateien (*.zip)|*.zip', ENU = 'ZIP Files (*.zip)|*.zip';
    begin
        case uppercase(FileMgt.GetExtension(FileName)) OF
            'XLSX':
                OutExt := ExcelFileTypeTok;
            'XML':
                OutExt := XMLFileTypeTok;
            'TXT':
                OutExt := TXTFileTypeTok;
            'RDL', 'RDLC':
                OutExt := RDLFileTypeTok;
            'ZIP':
                OutExt := ZIPFileTypeTok;
        end;
        IF OutExt = '' then
            OutExt := AllFilesDescriptionTxt
        else
            OutExt += '|' + AllFilesDescriptionTxt;

        TempTenantMedia.Content.CreateInStream(InStr, FileEncoding);
        IsDownloaded := DOWNLOADFROMSTREAM(InStr, ExportLbl, Path, OutExt, FileName);
        if IsDownloaded then
            exit(FileName);
        exit('');
    end;

    procedure GetMediaFieldAsText(var FldRef: FieldRef; Base64Encode: Boolean; var MediaContentAsText: Text) OK: Boolean
    var
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        MediaID: Guid;
        IStream: InStream;
    begin
        Clear(MediaContentAsText);
        if FldRef.Type <> FieldType::Media then
            exit(false);
        if not Evaluate(MediaID, Format(FldRef.Value)) then
            exit(false);
        If (Format(FldRef.Value) = '') then
            exit(true);
        if IsNullGuid(MediaID) then
            exit(true);
        TenantMedia.Get(MediaID);
        TenantMedia.calcfields(Content);
        if TenantMedia.Content.HasValue then begin
            TenantMedia.Content.CreateInStream(IStream);
            if Base64Encode then
                MediaContentAsText := Base64Convert.ToBase64(IStream)
            else
                IStream.ReadText(MediaContentAsText);
        end;
    end;

    procedure GetBlobFieldAsText(var FldRef: FieldRef; Base64Encode: Boolean; var BlobContentAsText: Text) OK: Boolean
    var
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
    begin
        OK := true;
        TenantMedia.Content := FldRef.Value;
        if not TenantMedia.Content.HasValue then
            exit(false);
        TenantMedia.Content.CreateInStream(IStream);
        if Base64Encode then
            BlobContentAsText := Base64Convert.ToBase64(IStream)
        else
            IStream.ReadText(BlobContentAsText);
    end;

    var
        RecordIDList: List of [RecordId];
        TablesList: List of [Integer];
        XDoc: XmlDocument;
}