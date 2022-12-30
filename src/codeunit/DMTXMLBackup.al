codeunit 110003 DMTXMLBackup
{

    procedure Export();
    begin
        MarkAll();
        ExportXML('');
    end;

    procedure Export(TablesToExport: List of [Integer]; exportFileBaseName: Text);
    begin
        MarkSelected(TablesToExport);
        ExportXML(exportFileBaseName);
    end;

    procedure Import();
    var
        allObj: Record AllObj;
        DMTSetup: Record DMTSetup;
        TargetRef: RecordRef;
        FldRef: FieldRef;
        FileFound: Boolean;
        Start: DateTime;
        serverFile: File;
        InStr: InStream;
        FieldNodeID: Integer;
        TableNodeID: Integer;
        FileName: Text;
        TableNodeName: Text;
        XFieldNode: XmlNode;
        XRecordNode: XmlNode;
        XTableNode: XmlNode;
        XFieldList: XmlNodeList;
        XRecordList: XmlNodeList;
        XTableList: XmlNodeList;
    begin
        if DMTSetup.Get() and (DMTSetup."Backup.xml File Path" <> '') then
            if serverFile.Open(DMTSetup."Backup.xml File Path") then begin
                FileFound := true;
                serverFile.CreateInStream(InStr);
            end;

        if not FileFound then
            if not UploadIntoStream('Select a Backup.XML file', '', 'XML Files|*.xml', FileName, InStr) then begin
                exit;
            end;

        Start := CurrentDateTime;
        Clear(XDoc);
        if not XmlDocument.ReadFrom(InStr, XDoc) then
            Error('reading xml failed');
        XDoc.SelectNodes('//DMT/child::*', XTableList);
        foreach XTableNode in XTableList do begin
            Evaluate(TableNodeID, GetAttributeValue(XTableNode, 'ID'));
            TableNodeName := GetAttributeValue(XTableNode, 'NAME');
            XTableNode.SelectNodes('child::RECORD', XRecordList); // select all element children
            foreach XRecordNode in XRecordList do begin
                // Check for renumbering
                if not allObj.Get(allObj."Object Type"::Table, TableNodeID) then
                    if TableNodeName <> '' then begin
                        allObj.SetRange("Object Type", allObj."Object Type"::Table);
                        allObj.SetFilter("Object Name", ConvertStr(TableNodeName, '_', '?'));
                        if allObj.FindFirst() then
                            TableNodeID := allObj."Object ID";
                    end;
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
                if not TargetRef.Modify() then TargetRef.Insert();
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

    local procedure ExportXML(exportFileBaseName: Text);
    var
        allObj: Record AllObj;
        Company: Record Company;
        tempTenantMedia: Record "Tenant Media" temporary;
        tableID: Integer;
        oStr: OutStream;
        fieldDefinitionNode: XmlNode;
        rootNode: XmlNode;
        tableNode: XmlNode;
    begin
        // DOKUMENT
        Clear(XDoc);
        XDoc := XmlDocument.Create();

        // ROOT
        rootNode := XmlElement.Create('DMT').AsXmlNode();
        XDoc.Add(rootNode);
        AddAttribute(rootNode, 'Version', '1.1');

        // Table Loop
        CreateTableIDList(TablesList);
        foreach tableID in TablesList do
            if GetTableLineCount(tableID) > 0 then begin
                allObj.Get(allObj."Object Type"::Table, tableID);
                tableNode := XmlElement.Create(CreateTagName(allObj."Object Name")).AsXmlNode();
                rootNode.AsXmlElement().Add(tableNode);

                AddAttribute(tableNode, 'ID', Format(tableID));
                AddAttribute(tableNode, 'NAME', ConvertStr(allObj."Object Name", '"', '_'));
                fieldDefinitionNode := CreateFieldDefinitionNode(tableID);
                tableNode.AsXmlElement().Add(fieldDefinitionNode);
                AddTable(tableNode, allObj."Object ID");
            end;

        tempTenantMedia.Content.CreateOutStream(oStr);
        XDoc.WriteTo(oStr);
        // Compose Export Filename
        if exportFileBaseName = '' then
            exportFileBaseName := 'Backup_';
        Company.Get(CompanyName);
        if Company."Display Name" <> '' then
            exportFileBaseName += Company."Display Name"
        else
            exportFileBaseName += Company.Name;
        exportFileBaseName += Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2>_<Seconds,2>');
        exportFileBaseName += '.xml';
        exportFileBaseName := ConvertStr(exportFileBaseName, '<>*\/|"', '_______');
        DownloadBlobContent(tempTenantMedia, exportFileBaseName, TextEncoding::UTF8);

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

    local procedure AddTable(var _XMLNode_Start: XmlNode; i_TableID: Integer);
    var
        ID: RecordId;
        recRef: RecordRef;
        fldRef: FieldRef;
        i: Integer;
        keyFieldID: Integer;
        fieldIDsList: List of [Integer];
        fieldValueAsText: Text;
        fieldNode: XmlNode;
        recordNode: XmlNode;
        textNode: XmlText;
    begin
        foreach ID in RecordIDList do begin
            if ID.TableNo = i_TableID then begin
                recordNode := XmlElement.Create('RECORD').AsXmlNode();
                _XMLNode_Start.AsXmlElement().Add(recordNode);
                recRef.Get(ID);
                fieldIDsList := GetListOfKeyFieldIDs(recRef);
                // Add Key Fields As Attributes
                foreach keyFieldID in fieldIDsList do begin
                    fldRef := recRef.Field(keyFieldID);
                    AddAttribute(recordNode, CreateTagName(fldRef.Name), GetFldRefValueAsText(fldRef));
                end;
                // Add Fields with Value
                for i := 1 to recRef.FieldCount do begin
                    fldRef := recRef.FieldIndex(i);
                    if not FldRefIsEmpty(fldRef) then begin
                        fieldNode := XmlElement.Create('FIELD').AsXmlNode();
                        recordNode.AsXmlElement().Add(fieldNode);
                        AddAttribute(fieldNode, 'ID', Format(fldRef.Number));
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
        InitRef: RecordRef;
    begin
        InitRef.Open(FldRef.Record().Number);
        InitRef.Init();
        if FldRef.Type in [FieldType::Blob] then
            FldRef.CalcField();
        IsEmpty := (InitRef.Field(FldRef.Number).Value = FldRef.Value);
        exit(IsEmpty);
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
        case FldRef.Type of
            FldRef.Type::BigInteger:
                begin
                    Evaluate(BigIntegerType, ValueAsText);
                    FldRef.Value(BigIntegerType);
                end;
            FldRef.Type::Blob:
                begin
                    Clear(TenantMedia.Content);
                    if ValueAsText <> '' then begin
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
                    Evaluate(GUIDType, ValueAsText, 9);
                    FldRef.Value(GUIDType);
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
        case Format(FldRef.Type) of
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
                ValueText := Format(FldRef.Value, 0, 9);
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
            if (FldRef.Class = FldRef.Class::Normal) and FldRef.Active then begin
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
            AddAttribute(xField, 'Number', Format(fldRef.Number));
            AddAttribute(xField, 'Type', Format(fldRef.Type));
            if fldRef.Length <> 0 then
                AddAttribute(xField, 'Length', Format(fldRef.Length));
            if fldRef.Class <> FieldClass::Normal then
                AddAttribute(xField, 'Class', Format(fldRef.Class));
            if not fldRef.Active then
                AddAttribute(xField, 'Active', Format(fldRef.Active, 0, 9));
            AddAttribute(xField, 'Name', Format(fldRef.Name, 0, 9));
            AddAttribute(xField, 'Caption', Format(fldRef.Caption, 0, 9));
            if not (fldRef.Type in [FieldType::Blob, FieldType::Media, FieldType::MediaSet]) then
                AddAttribute(xField, 'InitValue', Format(recRef.Field(fldRef.Number).Value, 0, 9));
            if fldRef.Type = FieldType::Option then begin
                AddAttribute(xField, 'OptionCaption', Format(fldRef.OptionCaption));
                AddAttribute(xField, 'OptionMembers', Format(fldRef.OptionMembers));
            end;
            if fldRef.Relation <> 0 then
                AddAttribute(xField, 'Relation', Format(fldRef.Relation));
            XFieldDefinition.AsXmlElement().Add(xField);
        end;
    end;

    procedure CreateTableIDList(TablesFoundList: List of [Integer]);
    var
        ID: RecordId;
    begin
        foreach ID in RecordIDList do
            if not TablesFoundList.Contains(ID.TableNo) then
                TablesFoundList.Add(ID.TableNo);
    end;

    procedure CreateTagName(_Name: Text) _TagName: Text;
    begin
        _Name := DelChr(_Name, '=', ' ');
        _TagName := ConvertStr(_Name, '\/-.()', '______')
    end;

    procedure GetListOfKeyFieldIDs(var RecRef: RecordRef) KeyFieldIDsList: List of [Integer];
    var
        FieldRef: FieldRef;
        _KeyIndex: Integer;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for _KeyIndex := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(_KeyIndex);
            KeyFieldIDsList.Add(FieldRef.Number);
        end;
    end;

    procedure MarkAll();
    var
        _RecRef: RecordRef;
        TableID: Integer;
        TablesToExport: List of [Integer];
    begin
        TablesToExport.Add(Database::DMTSetup);
        TablesToExport.Add(Database::DMTDataFile);
        TablesToExport.Add(Database::DMTFieldMapping);
        TablesToExport.Add(Database::DMTReplacementsHeader);
        TablesToExport.Add(Database::DMTReplacementsLine);
        TablesToExport.Add(Database::DMTProcessingPlan);
        TablesToExport.Add(Database::DMTCopyTable);
        foreach TableID in TablesToExport do begin
            _RecRef.Open(TableID);
            if _RecRef.FindSet(false, false) then
                repeat
                    if not RecordIDList.Contains(_RecRef.RecordId) then
                        RecordIDList.Add(_RecRef.RecordId);
                until _RecRef.Next() = 0;
            _RecRef.Close();

        end;
    end;

    procedure MarkSelected(TablesToExport: List of [Integer]);
    var
        _RecRef: RecordRef;
        TableID: Integer;
    begin
        foreach TableID in TablesToExport do begin
            _RecRef.Open(TableID);
            if _RecRef.FindSet(false, false) then
                repeat
                    if not RecordIDList.Contains(_RecRef.RecordId) then
                        RecordIDList.Add(_RecRef.RecordId);
                until _RecRef.Next() = 0;
            _RecRef.Close();
        end;
    end;

    procedure DownloadBlobContent(var TempTenantMedia: Record "Tenant Media"; FileName: Text; FileEncoding: TextEncoding): Text
    var
        FileMgt: Codeunit "File Management";
        IsDownloaded: Boolean;
        InStr: InStream;
        OutExt: Text;
        Path: Text;
        AllFilesDescriptionTxt: TextConst DEU = 'Alle Dateien (*.*)|*.*', ENU = 'All Files (*.*)|*.*';
        ExcelFileTypeTok: TextConst DEU = 'Excel-Dateien (*.xlsx)|*.xlsx', ENU = 'Excel Files (*.xlsx)|*.xlsx';
        ExportLbl: TextConst DEU = 'Export', ENU = 'Export';
        RDLFileTypeTok: TextConst DEU = 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc', ENU = 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc';
        TXTFileTypeTok: TextConst DEU = 'Textdateien (*.txt)|*.txt', ENU = 'Text Files (*.txt)|*.txt';
        XMLFileTypeTok: TextConst DEU = 'XML-Dateien (*.xml)|*.xml', ENU = 'XML Files (*.xml)|*.xml';
        ZIPFileTypeTok: TextConst DEU = 'ZIP-Dateien (*.zip)|*.zip', ENU = 'ZIP Files (*.zip)|*.zip';
    begin
        case UpperCase(FileMgt.GetExtension(FileName)) of
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
        if OutExt = '' then
            OutExt := AllFilesDescriptionTxt
        else
            OutExt += '|' + AllFilesDescriptionTxt;

        TempTenantMedia.Content.CreateInStream(InStr, FileEncoding);
        IsDownloaded := DownloadFromStream(InStr, ExportLbl, Path, OutExt, FileName);
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
        if (Format(FldRef.Value) = '') then
            exit(true);
        if IsNullGuid(MediaID) then
            exit(true);
        TenantMedia.Get(MediaID);
        TenantMedia.CalcFields(Content);
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
        TablesList: List of [Integer];
        RecordIDList: List of [RecordId];
        XDoc: XmlDocument;
}