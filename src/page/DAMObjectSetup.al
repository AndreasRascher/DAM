page 91000 "DAM Setup"
{
    CaptionML = DEU = 'DAM Einrichtung', ENU = 'DAM Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DAM Setup";

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
                        field("Object ID Dataport (Export)"; Rec."Object ID Dataport (Export)") { ApplicationArea = All; }
                        field("Obj. ID Range Buffer Tables"; Rec."Obj. ID Range Buffer Tables") { ApplicationArea = All; }
                        field("Obj. ID Range XMLPorts"; Rec."Obj. ID Range XMLPorts") { ApplicationArea = All; }
                    }
                    group(Paths)
                    {
                        CaptionML = DEU = 'Pfade', ENU = 'Paths';
                        field("Default Export Folder Path"; Rec."Default Export Folder Path")
                        {
                            ApplicationArea = All;
                        }
                        field("Schema File Path"; Rec."Schema.xml File Path")
                        {
                            ApplicationArea = All;
                            trigger OnValidate()
                            begin
                                Rec."Schema.xml File Path" := DelChr(Rec."Schema.xml File Path", '<>', '"');
                            end;
                        }
                        field("Backup.xml File Path"; "Backup.xml File Path")
                        {
                            ApplicationArea = All;
                            trigger OnValidate()
                            begin
                                Rec."Backup.xml File Path" := DelChr(Rec."Default Export Folder Path", '<>', '"');
                            end;
                        }
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
        area(Processing)
        {
            action(CreateNAVExportObject)
            {
                CaptionML = DEU = 'NAV Export Dataport erstellen';
                ApplicationArea = All;
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

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
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ObjMgt: Codeunit ObjMgt;
                begin
                    ObjMgt.ImportNAVSchemaFile();
                end;
            }
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
            action(TableList)
            {
                ApplicationArea = All;
                Image = Table;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = page DAMTableList;
            }
        }
        area(Navigation)
        {
            action(Table_DAMFieldBuffer)
            {
                ApplicationArea = All;
                CaptionML = DEU = 'Schema anzeigen';
                Image = ShowMatrix;

                trigger OnAction()
                begin
                    Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, Database::DAMFieldBuffer));
                end;
            }
            action(Test)
            {
                ApplicationArea = all;

                trigger OnAction()
                var
                    DAMTestRunner: Codeunit DAMTestRunner;
                begin
                    DAMTestRunner.Run();
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