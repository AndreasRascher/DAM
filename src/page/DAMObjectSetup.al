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
                        field("Obj. ID Range Buffer Tables"; Rec."Obj. ID Range Buffer Tables") { ApplicationArea = All; }
                        field("Obj. ID Range XMLPorts"; Rec."Obj. ID Range XMLPorts") { ApplicationArea = All; }
                        field("Object ID Dataport (Export)"; Rec."Object ID Dataport (Export)") { ApplicationArea = All; }
                    }
                    group(Paths)
                    {
                        CaptionML = DEU = 'Pfade', ENU = 'Paths';
                        field("Default Export Folder Path"; Rec."Default Export Folder Path")
                        {
                            ApplicationArea = All;
                            trigger OnValidate()
                            begin
                                Rec."Default Export Folder Path" := DelChr(Rec."Default Export Folder Path", '<>', '"');
                            end;

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                LookUpFolderPath(Text);
                                Rec."Default Export Folder Path" := Text;
                            end;
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
                        field(SessionID; SessionId()) { ApplicationArea = all; }
                        field(UserID; UserId) { ApplicationArea = all; }
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateNAV2009ExportObject)
            {
                CaptionML = DEU = 'NAV2009 Export Dataport erstellen';
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
                    ObjGen.DownloadFileUTF8(ObjGen.CreateNAV2009Dataport(Rec."Object ID Dataport (Export)"), 'DAMExport.txt');
                end;
            }
            action(ImportNAV2009Schema)
            {
                CaptionML = DEU = 'NAV2009 Schema.txt importieren';
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

    procedure LookUpFolderPath(var Result: Text) OK: Boolean
    var
        FileRec: Record File;
    begin
        clear(Result);
        if Page.RunModal(Page::FileBrowser, FileRec) = Action::LookupOK then begin
            Result := FileRec.Path;
        end;
    end;

    trigger OnOpenPage()
    begin
        Rec.InsertWhenEmpty();
    end;

}