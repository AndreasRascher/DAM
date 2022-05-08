page 91000 "DMT Setup"
{
    CaptionML = DEU = 'Data Migration Tool Einrichtung', ENU = 'Data Migration Tool Setup';
    AdditionalSearchTermsML = DEU = 'DMT Einrichtung', ENU = 'DMT Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DMTSetup";
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
                Caption = 'Creeate NAV Export Object', comment = 'NAV Export Objekt erstellen';
                ApplicationArea = All;
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = New;
                RunObject = page NAVObjects;
            }
            action(ImportNAVSchema)
            {
                Caption = 'Import Schema.csv', comment = 'NAV Schema.csv importieren';
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
                Caption = 'Table List', Comment = 'Tabellenübersicht';
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
                Caption = 'Task List', Comment = 'Aufgabenliste';
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
                Caption = 'Error Log', Comment = 'Fehlerprotokoll';
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
                Caption = 'TestImportGenBuff';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                trigger OnAction()
                var
                    DMTGenBuffTable: Record DMTGenBuffTable;
                    TempBlob: Codeunit "Temp Blob";
                    GenBuffImport: XmlPort GenBuffImport;
                    Start: DateTime;
                    InStr: InStream;
                    FileName: Text;
                begin
                    TempBlob.CreateInStream(InStr);
                    if not UploadIntoStream('Select a *.csv file', '', 'CSV Files|*.csv', FileName, InStr) then begin
                        exit;
                    end;
                    Start := CurrentDateTime;
                    GenBuffImport.SetSource(InStr);
                    // GenBuffImport.SetFilename(FileName);
                    GenBuffImport.Import();
                    Message('Import abgeschlossen\Dauer %1', CurrentDateTime - Start);

                    if DMTGenBuffTable.FindFirst() then begin
                        DMTGenBuffTable.InitFirstLineAsCaptions(DMTGenBuffTable."Import from Filename");
                        Page.Run(Page::"DMTGenBufferList250");
                    end;
                end;
            }
            action(OpenGenBufferPage)
            {
                CaptionML = DEU = 'OpenGenBufferPage', ENU = 'OpenGenBufferPage';
                ApplicationArea = All;
                Image = ListPage;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                trigger OnAction()
                var
                    DMTGenBuffTable: Record DMTGenBuffTable;
                begin
                    if DMTGenBuffTable.FindFirst() then begin
                        DMTGenBuffTable.ShowImportDataForFile(DMTGenBuffTable."Import from Filename");
                    end;
                end;
            }
        }
        area(Processing)
        {
            action(XMLExport)
            {
                Caption = 'Create Backup', Comment = 'Backup erstellen';
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
                Caption = 'Import Backup', Comment = 'Backup importieren';
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