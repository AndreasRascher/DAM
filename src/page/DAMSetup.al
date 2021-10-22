page 91000 "DAM Setup"
{
    CaptionML = DEU = 'DAM Einrichtung', ENU = 'DAM Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DAM Setup";
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
                        field("Object ID Dataport (Export)"; Rec."Object ID Dataport (Export)") { ApplicationArea = All; ShowMandatory = true; }
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
                        field(UserID; UserId) { ApplicationArea = all; Caption = 'User ID'; }
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
                CaptionML = DEU = 'NAV Export Dataport erstellen';
                ApplicationArea = All;
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    ObjGen: Codeunit DAMObjectGenerator;
                begin
                    ObjGen.DownloadFileUTF8(ObjGen.CreateNAVDataport(Rec."Object ID Dataport (Export)"), 'DAMExport.txt');
                end;
            }
            action(ImportNAVSchema)
            {
                CaptionML = DEU = 'NAV Schema.txt importieren';
                ApplicationArea = All;
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    ObjMgt: Codeunit ObjMgt;
                begin
                    ObjMgt.ImportNAVSchemaFile();
                end;
            }
        }
        area(Reporting)
        {
            action(Table_DAMFieldBuffer)
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
                    Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, Database::DAMFieldBuffer));
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
                RunObject = page DAMTableList;
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
                RunObject = page DAMTaskList;
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
                RunObject = page "DAM Error Log List";
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
                    XMLBackup: Codeunit XMLBackup;
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
                    XMLBackup: Codeunit XMLBackup;
                begin
                    XMLBackup.Import();
                end;
            }
        }

    }
    [TryFunction]
    procedure TryFunctionTest()
    var
        MyDate: Date;
    begin
        Evaluate(MyDate, '1233453423');
    end;

    trigger OnOpenPage()
    begin
        Rec.InsertWhenEmpty();
    end;

}