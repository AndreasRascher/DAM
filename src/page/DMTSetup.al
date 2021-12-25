page 91000 "DMT Setup"
{
    CaptionML = DEU = 'DMT Einrichtung', ENU = 'DMT Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DMT Setup";
    PromotedActionCategoriesML = DEU = 'NAV,Backup,Listen,,', ENU = 'NAV,Backup,Lists,,';

    layout
    {
        area(Content)
        {
            group(General)
            {
                CaptionML = DEU = 'Allgemein', ENU = 'General';
                group(VerticalAlign)
                {
                    ShowCaption = false;
                    group(ObjectIDs)
                    {
                        CaptionML = DEU = 'Objekt IDs', ENU = 'Object IDs';
                        field("Object ID Export Object"; Rec."Object ID Export Object") { ApplicationArea = All; ShowMandatory = true; }
                        field("Obj. ID Range Buffer Tables"; Rec."Obj. ID Range Buffer Tables") { ApplicationArea = All; ShowMandatory = true; }
                        field("Obj. ID Range XMLPorts"; Rec."Obj. ID Range XMLPorts") { ApplicationArea = All; ShowMandatory = true; }
                    }
                    group(Paths)
                    {
                        CaptionML = DEU = 'Pfade', ENU = 'Paths';
                        field("Default Export Folder Path"; Rec."Default Export Folder Path") { ApplicationArea = All; }
                        field("Schema File Path"; Rec."Schema.xml File Path") { ApplicationArea = All; }
                        field("Backup.xml File Path"; Rec."Backup.xml File Path") { ApplicationArea = All; }
                    }
                    group(Performance)
                    {
                        field("Allow Usage of Try Function"; Rec."Allow Usage of Try Function") { ApplicationArea = all; }
                    }
                    group(Debugging)
                    {
                        field(SessionID; SessionId()) { ApplicationArea = all; Caption = 'SessionID'; }
                        field("UserID"; UserId) { ApplicationArea = all; Caption = 'User ID'; }
                    }
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(CreateNAVExportObject)
            {
                CaptionML = DEU = 'NAV Export Objekt erstellen';
                ApplicationArea = All;
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    ObjGen: Codeunit DMTObjectGenerator;
                    Choice: Integer;
                    NAVVersionSelectionTok: TextConst DEU = 'Dataport (Versionen bis NAV2009R2),XMLPort (Versionen NAV2013 bis NAV2018 sowie Business Central 13 + 14),Abbrechen',
                                                   ENU = 'Dataport (Versions up to NAV2009R2),XMLPort (Versions from NAV2013 to NAV2018 and Business Central 13 & 14),Cancel';
                begin
                    Choice := StrMenu(NAVVersionSelectionTok, 3);
                    case Choice of
                        1:
                            ObjGen.DownloadFileUTF8(ObjGen.GetNavClassicDataport(Rec."Object ID Export Object"),
                            'Dataport_' + format(Rec."Object ID Export Object") + '_DMTExport.txt');
                        2:
                            ObjGen.DownloadFileUTF8(ObjGen.GetNAVRTCXMLPort(Rec."Object ID Export Object"),
                            'XMLPort_' + format(Rec."Object ID Export Object") + '_DMTExport.txt');
                    end;
                end;
            }
            action(ImportNAVSchema)
            {
                CaptionML = DEU = 'NAV Schema.csv importieren';
                ApplicationArea = All;
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    ObjMgt: Codeunit DMTObjMgt;
                begin
                    ObjMgt.ImportNAVSchemaFile();
                end;
            }
        }
        area(Reporting)
        {
            action("Table_DMTFieldBuffer")
            {
                ApplicationArea = All;
                CaptionML = DEU = 'Schema anzeigen';
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Image = ShowMatrix;
                Visible = false;

                trigger OnAction()
                begin
                    Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, Database::DMTFieldBuffer));
                end;
            }
            action(TableList)
            {
                CaptionML = DEU = 'Tabellenübersicht', ENU = 'Table List';
                ApplicationArea = All;
                Image = Table;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                RunObject = page DMTTableList;
            }
            action(TaskList)
            {
                CaptionML = DEU = 'Aufgabenliste', ENU = 'Task List';
                ApplicationArea = All;
                Image = TaskList;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                RunObject = page DMTTaskList;
            }
            action(ErrorLog)
            {
                CaptionML = DEU = 'Fehlerprotokoll', ENU = 'Error Log';
                ApplicationArea = All;
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                RunObject = page "DMT Error Log List";
            }
            action(TestImportGenBuffer)
            {
                CaptionML = DEU = 'TestImportGenBuff', ENU = 'TestImportGenBuff';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    GenBuffImport: XmlPort GenBuffImport;
                    InStr: InStream;
                    FileName: Text;
                    Start: DateTime;
                begin
                    TempBlob.CreateInStream(InStr);
                    if not UploadIntoStream('Select a *.csv file', '', 'CSV Files|*.csv', FileName, InStr) then begin
                        exit;
                    end;
                    Start := CurrentDateTime;
                    GenBuffImport.SetSource(InStr);
                    GenBuffImport.Import();
                    Message('Import abgeschlossen\Dauer %1', CurrentDateTime - Start);
                end;
            }
        }
        area(Processing)
        {
            action(XMLExport)
            {
                CaptionML = DEU = 'Backup erstellen';
                ApplicationArea = All;
                Image = CreateXMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Export();
                end;
            }
            action(XMLImport)
            {
                CaptionML = DEU = 'Backup importieren';
                ApplicationArea = All;
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Import();
                end;
            }
        }

    }
    trigger OnOpenPage()
    begin
        rec.InsertWhenEmpty();
    end;
}