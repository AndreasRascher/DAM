page 81137 "Copy Report Helper"
{
    Caption = 'Copy Report Helper';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Report Metadata";
    SaveValues = true;
    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(RemoveALReportWhiteSpaceOption; removeALWhitespaceOption) { Caption = 'Remove al whitespace'; }
                field(addSetDataGetDataCustomCodeOption; addSetDataGetDataCustomCodeOption) { Caption = 'Add SetData GetData CustomCode'; }
            }
            repeater(Repeater)
            {
                field(ReportID; Rec.ID) { ApplicationArea = All; }
                field(ReportName; Rec.Name) { ApplicationArea = All; }
                field(ReportCaption; Rec.Caption) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadReport)
            {
                ApplicationArea = All;
                Image = Download;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ReportMetadata_SELECTED: Record "Report Metadata";
                    FileContents: List of [Text];
                    FileNames: List of [Text];
                    ReportALCode, ReportRDLCLayout : text;
                    FileNameBase: text;
                begin
                    if not GetSelection(ReportMetadata_SELECTED) then exit;
                    ReportMetadata_SELECTED.FindSet();
                    repeat
                        FileNameBase := ConvertStr(ReportMetadata_SELECTED.Name, '<>*\/|"', '_______');
                        // Layout File
                        Clear(ReportRDLCLayout);
                        GetDatabaseReportRDLC(ReportRDLCLayout, ReportMetadata_SELECTED.ID);
                        if addSetDataGetDataCustomCodeOption then
                            AddCustomCode(ReportRDLCLayout);
                        FileNames.Add(FileNameBase + '.rdlc');
                        FileContents.Add(ReportRDLCLayout);
                        // AL Code File
                        Clear(ReportALCode);
                        ReadALCode(ReportALCode, ReportMetadata_SELECTED.ID);
                        if removeALWhitespaceOption then
                            RemoveALReportWhiteSpace(ReportALCode);
                        SetRDLCFilenameProperty(ReportALCode, FileNameBase + '.rdlc');
                        FileNames.Add(FileNameBase + '.al');
                        FileContents.Add(ReportALCode);
                    until ReportMetadata_SELECTED.Next() = 0;
                    DownloadReportFilesAsZip(FileNames, FileContents);
                end;
            }
        }
    }

    views
    {
        view(Sales)
        {
            Caption = 'Sales', Comment = 'Einkauf';
            Filters = where(FirstDataItemTableID = filter('36|110|112|114'), ProcessingOnly = const(false));
        }
        view(Purchase)
        {
            Caption = 'Purchase', Comment = 'Verkauf';
            Filters = where(FirstDataItemTableID = filter('38|120|122|124|6650'), ProcessingOnly = const(false));
        }
    }

    procedure GetSelection(var ReportMetadata_SELECTED: Record "Report Metadata") HasLines: Boolean
    begin
        Clear(ReportMetadata_SELECTED);
        CurrPage.SetSelectionFilter(ReportMetadata_SELECTED);
        HasLines := ReportMetadata_SELECTED.FindFirst();
    end;

    local procedure ReadALCode(var ReportALCode: Text; ReportID: integer)
    var
        AppObjectMetadata: Record "Application Object Metadata";
        BText: BigText;
        IStr: InStream;
        ALCodeNotAvailableErr: Label 'User AL Code is not available for the %1 %2. Enable with Powershell command:\set-NAVServerConfiguration -ServerInstance BC -KeyName ProtectNAVAppSourceFiles -KeyValue false -ApplyTo All';
    begin
        Clear(ReportALCode);
        AppObjectMetadata.SetRange("Object Type", AppObjectMetadata."Object Type"::Report);
        AppObjectMetadata.SetRange("Object ID", ReportID);
        AppObjectMetadata.FindFirst();
        AppObjectMetadata.CalcFields("User AL Code");
        if not AppObjectMetadata."User AL Code".HasValue then
            Error(ALCodeNotAvailableErr, AppObjectMetadata."Object Type", AppObjectMetadata."Object ID");
        AppObjectMetadata."User AL Code".CreateInStream(IStr);
        BText.Read(IStr);
        ReportALCode := Format(BText);
    end;

    procedure CustomCodeLib_SetGetDataByName() CustomCode: Text
    var
        Content: TextBuilder;
    begin
        Content.AppendLine(''' Source: https://github.com/AndreasRascher/RDLCReport_CustomCode');
        Content.AppendLine(''' =================');
        Content.AppendLine(''' Global variables');
        Content.AppendLine(''' =================');
        Content.AppendLine('Shared HeaderData As Microsoft.VisualBasic.Collection');
        Content.AppendLine('Shared FooterData As Microsoft.VisualBasic.Collection');
        Content.AppendLine('');
        Content.AppendLine(''' ==========================');
        Content.AppendLine(''' Get Header or Footer Value ');
        Content.AppendLine(''' ==========================');
        Content.AppendLine('');
        Content.AppendLine(''' Key = position number or name');
        Content.AppendLine('Public Function HeaderVal(Key as Object)');
        Content.AppendLine('  Return GetValue(HeaderData,Key)');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine('Public Function FooterVal(Key as Object)');
        Content.AppendLine('  Return GetValue(FooterData,Key)');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine('Public Function GetValue(ByRef Data as Object,Key as Object)');
        Content.AppendLine('  ''if Key As Number');
        Content.AppendLine('  If IsNumeric(Key) then');
        Content.AppendLine('    Dim i as Long');
        Content.AppendLine('    Integer.TryParse(Key,i)');
        Content.AppendLine('    if (i=0) then');
        Content.AppendLine('    return "Index starts at 1"');
        Content.AppendLine('    end if');
        Content.AppendLine('    if (Data.Count = 0) OR (i = 0) OR (i >Data.Count) then');
        Content.AppendLine('      Return "Invalid Index: ''"+CStr(i)+"''! Collection Count = "+ CStr(Data.Count)');
        Content.AppendLine('    end if  ');
        Content.AppendLine('    Return Data.Item(i)');
        Content.AppendLine('  end if');
        Content.AppendLine('');
        Content.AppendLine('  ''if Key As String');
        Content.AppendLine('  Key = CStr(Key).ToUpper() '' Key is Case Insensitive');
        Content.AppendLine('  Select Case True');
        Content.AppendLine('    Case IsNothing(Data)');
        Content.AppendLine('      Return "CollectionEmpty"');
        Content.AppendLine('    Case IsNothing(Key)');
        Content.AppendLine('      Return "KeyEmpty"');
        Content.AppendLine('    Case (not Data.Contains(Key))');
        Content.AppendLine('      Return "Key not found: ''"+CStr(Key)+"''!"');
        Content.AppendLine('    Case Data.Contains(Key)');
        Content.AppendLine('      Return Data.Item(Key)');
        Content.AppendLine('    Case else');
        Content.AppendLine('      Return "Something else failed"');
        Content.AppendLine('  End Select ');
        Content.AppendLine('');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine(''' ===========================================');
        Content.AppendLine(''' Set Header and Footer values from the body ');
        Content.AppendLine(''' ===========================================');
        Content.AppendLine('');
        Content.AppendLine('Public Function SetHeaderDataAsKeyValueList(NewData as Object)');
        Content.AppendLine('  SetDataAsKeyValueList(HeaderData,NewData)');
        Content.AppendLine('  Return True ''Set Control to Hidden=true');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine('Public Function SetFooterDataAsKeyValueList(NewData as Object)');
        Content.AppendLine('  FooterData = New Microsoft.VisualBasic.Collection ');
        Content.AppendLine('  SetDataAsKeyValueList(FooterData,NewData)');
        Content.AppendLine('  Return True ''Set Control to Hidden=true');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine('Public Function SetDataAsKeyValueList(ByRef SharedData as Object,NewData as Object)');
        Content.AppendLine('  Dim i as integer');
        Content.AppendLine('  Dim words As String() = Split(CStr(NewData),Chr(177))');
        Content.AppendLine('  Dim Key As String');
        Content.AppendLine('  Dim Value As String');
        Content.AppendLine('  For i = 1 To UBound(words)   ');
        Content.AppendLine('    if ((i mod 2) = 0) then');
        Content.AppendLine('      Key   = Cstr(Choose(i-1, Split(Cstr(NewData),Chr(177))))     ');
        Content.AppendLine('      Value = Cstr(Choose(i, Split(Cstr(NewData),Chr(177))))');
        Content.AppendLine('      AddKeyValue(SharedData,Key,Value)');
        Content.AppendLine('    end if');
        Content.AppendLine('    '' If last item in list only has a key');
        Content.AppendLine('    if (i = UBound(words)) and ((i mod 2) = 1) then');
        Content.AppendLine('      Key   = Cstr(Choose(i, Split(Cstr(NewData),Chr(177))))     ');
        Content.AppendLine('      Value = ""');
        Content.AppendLine('      AddKeyValue(SharedData,Key,Value)');
        Content.AppendLine('    end if');
        Content.AppendLine('  Next ');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine('Public Function AddValue(ByRef Data as Object,Value as Object)');
        Content.AppendLine('  if IsNothing(Data) then');
        Content.AppendLine('     Data = New Microsoft.VisualBasic.Collection');
        Content.AppendLine('  End if');
        Content.AppendLine('  Data.Add(Value,Data.Count +1)');
        Content.AppendLine('  Return Data.Count  ');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine('Public Function AddKeyValue(ByRef Data as Object, Key as Object,Value as Object)');
        Content.AppendLine('  if IsNothing(Data) then');
        Content.AppendLine('     Data = New Microsoft.VisualBasic.Collection');
        Content.AppendLine('  End if');
        Content.AppendLine('');
        Content.AppendLine('  Dim RealKey as String');
        Content.AppendLine('  if (CStr(Key) <> "") Then');
        Content.AppendLine('    RealKey = CStr(Key).ToUpper()');
        Content.AppendLine('  else');
        Content.AppendLine('    RealKey = CStr(Data.Count +1)');
        Content.AppendLine('  End if');
        Content.AppendLine('  '' Replace value if it already exists');
        Content.AppendLine('  if Data.Contains(RealKey) then');
        Content.AppendLine('     Data.Remove(RealKey)');
        Content.AppendLine('  End if');
        Content.AppendLine('');
        Content.AppendLine('  Data.Add(Value,RealKey)   ');
        Content.AppendLine('');
        Content.AppendLine('  Return Data.Count');
        Content.AppendLine('End Function');

        CustomCode := Content.ToText();
    end;


    procedure GetDatabaseReportRDLC(var ReportRDLCLayout: Text; ReportID: Integer) OK: Boolean
    var
        InStr: InStream;
        RDLXml: XmlDocument;
    begin
        if not Report.RdlcLayout(ReportID, InStr) then
            exit(false);
        OK := XmlDocument.ReadFrom(InStr, RDLXml);
        RDLXML.WriteTo(ReportRDLCLayout);
    end;

    procedure DownloadReportFilesAsZip(FileNames: List of [Text]; FileContents: List of [Text])
    var
        DataCompression: Codeunit "Data Compression";
        FileBlob: Codeunit "Temp Blob";
        IStr: InStream;
        Index: Integer;
        OStr: OutStream;
        FileContent, FileName : Text;
        ZIPFileTypeTok: TextConst DEU = 'ZIP-Dateien (*.zip)|*.zip', ENU = 'ZIP Files (*.zip)|*.zip';
    begin
        DataCompression.CreateZipArchive();
        for Index := 1 to FileNames.Count do begin
            FileName := FileNames.Get(Index);
            FileContent := FileContents.Get(Index);
            Clear(FileBlob);
            FileBlob.CreateOutStream(OStr);
            OStr.WriteText(FileContent);
            FileBlob.CreateInStream(IStr);
            DataCompression.AddEntry(IStr, FileName);
        end;
        Clear(FileBlob);
        FileBlob.CreateOutStream(OStr);
        DataCompression.SaveZipArchive(OStr);
        FileBlob.CreateInStream(IStr);
        FileName := 'ReportsWithLayout.zip';
        DownloadFromStream(iStr, 'Download', 'ToFolder', ZIPFileTypeTok, FileName);
    end;

    procedure SetRDLCFilenameProperty(var ReportALCode: Text; RDLCFileName: Text)
    var
        Lines: List of [Text];
        CRLF: Text[2];
        ReportALCodeNew: TextBuilder;
        Index: Integer;
    begin
        if not ReportALCode.Contains('RDLCLayout = ') then exit;
        CRLF[1] := 13;
        CRLF[2] := 10;
        Lines := ReportALCode.Split(CRLF);
        for Index := 1 to Lines.Count do begin
            if Lines.get(Index).Trim().StartsWith('RDLCLayout =') then begin
                Lines.Set(Index, StrSubstNo('    RDLCLayout = ''%1'';'));
            end;
            ReportALCodeNew.AppendLine(Lines.Get(Index));
        end;
        ReportALCode := ReportALCodeNew.ToText().TrimEnd();
    end;

    procedure RemoveALReportWhiteSpace(var ReportALCode: Text)
    var
        Lines: List of [Text];
        CRLF: Text[2];
        ReportALCodeNew: TextBuilder;
        Index: Integer;
        PropertyLineCount: Integer;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        Lines := ReportALCode.Split(CRLF);
        for Index := 1 to Lines.Count do begin

            clear(PropertyLineCount);
            if (Index <= (Lines.Count - 2)) then
                if (Lines.Get(Index + 1).Trim() = '{') and (Lines.Get(Index + 2).Trim() = '}') then
                    PropertyLineCount := 2;

            if (Index <= (Lines.Count - 3)) then
                if (Lines.Get(Index + 1).Trim() = '{') and (Lines.Get(Index + 3).Trim() = '}') then
                    PropertyLineCount := 3;

            if (Index <= (Lines.Count - 4)) then
                if (Lines.Get(Index + 1).Trim() = '{') and (Lines.Get(Index + 4).Trim() = '}') then
                    PropertyLineCount := 4;

            case PropertyLineCount of
                // Compress empty brackets to one line
                2:
                    begin
                        ReportALCodeNew.AppendLine(Lines.Get(Index) + ' {}');
                        Index += 2;
                    end;
                // Compress brackets with one statement to one line
                3:
                    begin
                        ReportALCodeNew.AppendLine(StrSubstNo('%1 {%2}', Lines.Get(Index), Lines.Get(Index + 2)));
                        Index += 3;
                    end;
                // Compress brackets with one statement to two lines
                4:
                    begin
                        ReportALCodeNew.AppendLine(StrSubstNo('%1 {%2 %3}', Lines.Get(Index).TrimStart(), Lines.Get(Index + 2).TrimStart(), Lines.Get(Index + 3).TrimStart()));
                        Index += 4;
                    end;
                else
                    ReportALCodeNew.AppendLine(Lines.Get(Index));
            end;
        end;
        ReportALCode := ReportALCodeNew.ToText().TrimEnd();
    end;

    procedure AddCustomCode(var ReportRDLCLayout: Text);
    var
        NewCustomCode: text;
        RDLXML: XmlDocument;
        CustomCodeFirstLineTok: Label 'Source: https://github.com/AndreasRascher/RDLCReport_CustomCode', Locked = true;
    begin
        if ReportRDLCLayout.Contains(CustomCodeFirstLineTok) then exit;
        XmlDocument.ReadFrom(ReportRDLCLayout, RDLXml);
        NewCustomCode := CustomCodeLib_SetGetDataByName();
        AppendCustomCode(RDLXml, NewCustomCode);
        RDLXml.WriteTo(ReportRDLCLayout);
    end;

    procedure AppendCustomCode(var RDLXml: XmlDocument; NewCustomCode: text)
    var
        XmlNsMgr: XmlNamespaceManager;
        XCustomCode: XmlNode;
        NewLine: Text[2];
    begin
        AddNamespaces(XmlNsMgr, RDLXml); // adds default namespace with ns prefix
        if not RDLXml.SelectSingleNode('//ns:Report/ns:Code/text()', XmlNsMgr, XCustomCode) then
            exit;
        NewLine[1] := 13;
        NewLine[2] := 10;
        XCustomCode.AsXmlText().Value(XCustomCode.AsXmlText().Value + NewLine + NewCustomCode);
        if not RDLXml.SelectSingleNode('//ns:Report/ns:Code/text()', XmlNsMgr, XCustomCode) then
            exit;
    end;

    procedure AddNamespaces(var _XmlNsMgr: XmlNamespaceManager; _XMLDoc: XmlDocument)
    var
        _XmlAttributeCollection: XmlAttributeCollection;
        _XmlAttribute: XmlAttribute;
        _XMLElement: XmlElement;
    begin
        _XmlNsMgr.NameTable(_XMLDoc.NameTable());
        _XMLDoc.GetRoot(_XMLElement);
        _XmlAttributeCollection := _XMLElement.Attributes();
        if _XMLElement.NamespaceUri() <> '' then
            //_XmlNsMgr.AddNamespace('', _XMLElement.NamespaceUri());
            _XmlNsMgr.AddNamespace('ns', _XMLElement.NamespaceUri());
        Foreach _XmlAttribute in _XmlAttributeCollection do
            if StrPos(_XmlAttribute.Name(), 'xmlns:') = 1 then
                _XmlNsMgr.AddNamespace(DELSTR(_XmlAttribute.Name(), 1, 6), _XmlAttribute.Value());
    end;

    var
        [InDataSet]
        removeALWhitespaceOption, addSetDataGetDataCustomCodeOption : Boolean;
}