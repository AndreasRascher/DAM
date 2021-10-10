codeunit 91005 XMLBackup
{

    procedure Export();
    begin
        MarkAll();
        ExportXML();
    end;

    procedure Import();
    var
        TargetRef: RecordRef;
        FldRef: FieldRef;
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
    begin
        if not UploadIntoStream('Select a Backup.XML file', '', 'XML Files|*.xml', FileName, InStr) then
            exit;
        Clear(XDoc);
        if not XmlDocument.ReadFrom(InStr, XDoc) then
            Error('reading xml failed');
        XDoc.SelectNodes('//DAMTable', XTableList);
        foreach XTableNode in XTableList do begin
            Evaluate(TableNodeID, GetAttributeValue(XTableNode, 'ID'));
            Clear(TargetRef);
            TargetRef.Open(TableNodeID, false);
            //XRecordList := XTableNode.AsXmlElement().GetChildNodes();
            XTableNode.SelectNodes('child::*', XRecordList); // select all element children
            foreach XRecordNode in XRecordList do begin
                //XFieldList := XRecordNode.AsXmlElement().GetChildNodes();
                XRecordNode.SelectNodes('child::*', XFieldList); // select all element children
                foreach XFieldNode in XFieldList do begin
                    Evaluate(FieldNodeID, GetAttributeValue(XFieldNode, 'ID'));
                    FldRef := TargetRef.Field(FieldNodeID);
                    if XFieldNode.AsXmlElement().InnerText <> '' then
                        EvaluateFldRef(FldRef, XFieldNode.AsXmlElement().InnerText);
                end;
                if not TargetRef.modify() then TargetRef.insert();
            end;
        end;
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

    PROCEDURE XMLFormatFieldRef(VAR _FldRef: FieldRef) _ValueInXMLFormat: Text;
    VAR
        _Bool: Boolean;
        _Date: Date;
        _Time: Time;
        _DateTime: DateTime;
        _Duration: Duration;
        _Integer: Integer;
    BEGIN
        CASE UPPERCASE(Format(_FldRef.TYPE)) OF
            'DECIMAL', 'INTEGER', 'BIGINTEGER':
                exit(Format(_FldRef.VALUE));
            'CODE', 'TEXT', 'TABLEFILTER', 'BIGTEXT', 'DATEFORMULA', 'GUID':
                exit(Format(_FldRef.VALUE));
            'BOOLEAN':
                BEGIN
                    _Bool := _FldRef.VALUE;
                    IF _Bool then exit('1');
                    exit('0');
                END;
            'OPTION':
                BEGIN
                    _Integer := _FldRef.VALUE;
                    exit(Format(_Integer));
                END;
            'DATE':
                BEGIN
                    _Date := _FldRef.VALUE;
                    exit(Format(_Date, 0, 9));
                END;
            'TIME':
                BEGIN
                    _Time := _FldRef.VALUE;
                    exit(Format(_Time, 0, 9));
                END;
            'DATETIME':
                BEGIN
                    _DateTime := _FldRef.VALUE;
                    exit(Format(_DateTime, 0, 9));
                END;
            'DURATION':
                BEGIN
                    _Duration := _FldRef.VALUE;
                    exit(Format(_Duration, 0, 9));
                END;
            ELSE
                ERROR('Unbehandelter Datentyp:%1', UPPERCASE(Format(_FldRef.TYPE)));
        END;
    END;

    PROCEDURE IsFieldEmpty(VAR _FieldRef: FieldRef) IsEmpty: Boolean;
    VAR
        _GUID: GUID;
        _Date: Date;
        _Time: Time;
        _DateTime: DateTime;
    BEGIN
        CASE UPPERCASE(Format(_FieldRef.TYPE)) OF
            'DECIMAL', 'INTEGER', 'BIGINTEGER':
                exit(Format(_FieldRef.VALUE) = '0');
            'CODE', 'TEXT', 'TABLEFILTER', 'BIGTEXT':
                exit(Format(_FieldRef.VALUE) = '');
            'OPTION':
                exit(Format(_FieldRef.VALUE) = SELECTSTR(1, _FieldRef.OPTIONCAPTION));
            'BOOLEAN':
                exit(Format(_FieldRef.VALUE) = 'FALSE');
            'DATE':
                IF EVALUATE(_Date, Format(_FieldRef.VALUE)) then
                    exit(_Date = 0D);
            'TIME':
                IF EVALUATE(_Time, Format(_FieldRef.VALUE)) then
                    exit(_Time = 0T);
            'DATETIME':
                IF EVALUATE(_DateTime, Format(_FieldRef.VALUE)) then
                    exit(_DateTime = 0DT);
            'BINARY', 'BLOB':
                exit(Format(_FieldRef.VALUE) = '');
            'DATEFORMULA':
                exit(Format(_FieldRef.VALUE) = '');
            'DURATION':
                exit(Format(_FieldRef.VALUE) = '0');
            'GUID':
                IF EVALUATE(_GUID, Format(_FieldRef.VALUE)) then
                    exit(ISNULLGUID(_GUID));
            'RECORDID':
                exit(Format(_FieldRef.VALUE) = '0');
            ELSE
                ERROR('Unbehandelter Datentyp:%1', UPPERCASE(Format(_FieldRef.TYPE)));
        END;
    end;

    local procedure ExportXML();
    VAR
        _AllObj: Record AllObj;
        TempTenantMedia: Record "Tenant Media" temporary;
        tableID: Integer;
        OStr: OutStream;
        _RootNode: XMLNode;
        _XMLNode_Table: XMLNode;
    begin
        // DOKUMENT
        Clear(XDoc);
        XDoc := XmlDocument.Create();

        // ROOT
        _RootNode := XmlElement.Create('DAM').AsXmlNode();
        XDoc.Add(_RootNode);
        AddAttribute(_RootNode, 'Version', '1.1');

        // Table Loop
        CreateTableIDList(TablesList);
        foreach tableID in Tableslist do
            IF GetTableLineCount(tableID) > 0 then begin
                _AllObj.GET(_AllObj."Object Type"::Table, tableID);
                _XMLNode_Table := XmlElement.Create(CreateTagName(_AllObj."Object Name")).AsXmlNode();
                _RootNode.AsXmlElement().Add(_XMLNode_Table);
                AddAttribute(_XMLNode_Table, 'ID', Format(tableID));
                AddTable(_XMLNode_Table, _AllObj."Object ID");
            end;

        TempTenantMedia.Content.CreateOutStream(OStr);
        XDoc.WriteTo(OStr);

        DownloadBlobContent(TempTenantMedia, 'Backup.xml');

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

    LOCAL procedure AddTable(VAR _XMLNode_Start: XMLNode; i_TableID: Integer);
    VAR
        TempTenantMedia: Record "Tenant Media" temporary;
        ID: RecordId;
        _RecRef: RecordRef;
        _FieldRef: FieldRef;
        _Boolean: Boolean;
        i: Integer;
        _XMLNode_Field: XMLNode;
        _XMLNode_Record: XMLNode;
        _XText: XmlText;
        _KeyFieldIDs: List of [Integer];
        _KeyFieldID: Integer;
    begin
        foreach ID in RecordIDList do begin
            if ID.TableNo = i_TableID then begin
                _XMLNode_Record := XmlElement.Create('RECORD').AsXmlNode();
                _XMLNode_Start.AsXmlElement().Add(_XMLNode_Record);
                _RecRef.Get(ID);
                GetListOfKeyFieldIDs(_RecRef, _KeyFieldIDs);
                // Add Key Fields As Attributes
                foreach _KeyFieldID in _KeyFieldIDs do begin
                    _FieldRef := _RecRef.FIELD(_KeyFieldID);
                    AddAttribute(_XMLNode_Record, CreateTagName(_FieldRef.NAME), XMLFormatFieldRef(_FieldRef));
                end;
                // Add Fields with Value
                for i := 1 TO _RecRef.FIELDCOUNT do begin
                    _FieldRef := _RecRef.FIELDINDEX(i);
                    IF NOT IsFieldEmpty(_FieldRef) then begin
                        _XMLNode_Field := XmlElement.Create('FIELD').AsXmlNode();
                        _XMLNode_Record.AsXmlElement().Add(_XMLNode_Field);
                        AddAttribute(_XMLNode_Field, 'ID', Format(_FieldRef.NUMBER));
                        AddAttribute(_XMLNode_Field, 'NAME', Format(_FieldRef.NAME));

                        CASE UPPERCASE(Format(_FieldRef.TYPE)) OF
                            'BLOB':
                                begin
                                    _FieldRef.CALCFIELD();
                                    CLEAR(TempTenantMedia);
                                    TempTenantMedia.Content := _FieldRef.VALUE;
                                    IF TempTenantMedia.Content.HASVALUE then begin
                                        AddBigText(_XMLNode_Field, _FieldRef)
                                    end;
                                end;
                            'BOOLEAN':
                                begin
                                    _Boolean := _FieldRef.VALUE;
                                    IF _Boolean then begin
                                        _XText := XmlText.Create('1');
                                        _XMLNode_Field.AsXmlElement().Add(_XText);
                                    end ELSE begin
                                        _XText := XmlText.Create('0');
                                        _XMLNode_Field.AsXmlElement().Add(_XText);
                                    end;
                                end;
                            'OPTION':
                                begin
                                    _XText := XmlText.Create(XMLFormatFieldRef(_FieldRef));
                                    _XMLNode_Field.AsXmlElement().Add(_XText);
                                end;
                            ELSE begin
                                    _XText := XmlText.Create(Format(_FieldRef.VALUE));
                                    _XMLNode_Field.AsXmlElement().Add(_XText);
                                end;
                        end; // end_CASE
                    end;
                end;
            end;
        end;
    end;

    LOCAL procedure AddBigText(VAR _XMLNode: XMLNode; VAR fr_FieldRef: FieldRef);
    VAR
        TempTenantMedia: record "Tenant Media" temporary;
        bt_BigText: BigText;
        is_InStream: InStream;
        XCDATA: XmlCData;
    begin
        fr_FieldRef.CALCFIELD();
        TempTenantMedia.Content := fr_FieldRef.VALUE;
        IF NOT TempTenantMedia.Content.HASVALUE then
            exit;
        TempTenantMedia.Content.CREATEINSTREAM(is_InStream);
        bt_BigText.READ(is_InStream);
        IF bt_BigText.LENGTH = 0 then
            exit;
        XCDATA := XmlCData.Create(Format(bt_BigText));
        _XMLNode.AsXmlElement().Add(XCDATA);
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
        _AllObj: Record AllObj;
        _RecRef: RecordRef;
    begin
        _AllObj.SETRANGE("Object Type", _AllObj."Object Type"::Table);
        _AllObj.SETRANGE("Object ID", 91000, 91002);
        IF _AllObj.FINDSET(FALSE, FALSE) then
            REPEAT
                _RecRef.OPEN(_AllObj."Object ID");
                IF _RecRef.FINDSET() then
                    REPEAT
                        if not RecordIDList.Contains(_RecRef.RecordId) then
                            RecordIDList.Add(_RecRef.RecordId);
                    UNTIL _RecRef.Next() = 0;
                _RecRef.close();
            UNTIL _AllObj.Next() = 0;
    end;

    procedure DownloadBlobContent(var TempTenantMedia: Record "Tenant Media"; FileName: Text): Text
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
    begin
        CASE UPPERCASE(FileMgt.GetExtension(FileName)) OF
            'XLSX':
                OutExt := ExcelFileTypeTok;
            'XML':
                OutExt := XMLFileTypeTok;
            'TXT':
                OutExt := TXTFileTypeTok;
            'RDL', 'RDLC':
                OutExt := RDLFileTypeTok;
        END;
        IF OutExt = '' then
            OutExt := AllFilesDescriptionTxt
        else
            OutExt += '|' + AllFilesDescriptionTxt;

        TempTenantMedia.Content.CreateInStream(InStr);
        IsDownloaded := DOWNLOADFROMSTREAM(InStr, ExportLbl, Path, OutExt, FileName);
        if IsDownloaded then
            exit(FileName);
        exit('');
    end;

    procedure EvaluateFldRef(var FldRef: FieldRef; ValueAsText: Text)
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
        CASE FldRef.TYPE OF
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
                Error('unhandled field type %1', FldRef.Type);
        end;
    end;

    var
        RecordIDList: List of [RecordId];
        TablesList: List of [Integer];
        XDoc: XmlDocument;
}