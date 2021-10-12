page 91000 "DAM Object Setup"
{
    CaptionML = DEU = 'DAM Objekt Einrichtung', ENU = 'DAM Object Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DAM Object Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                CaptionML = DEU = 'Allgemein', ENU = 'General';
                field("Obj. ID Range Buffer Tables"; Rec."Obj. ID Range Buffer Tables") { ApplicationArea = All; }
                field("Obj. ID Range XMLPorts"; Rec."Obj. ID Range XMLPorts") { ApplicationArea = All; }
                field("Object ID Dataport (Export)"; Rec."Object ID Dataport (Export)") { ApplicationArea = All; }
                field("Default Export Folder Path"; Rec."Default Export Folder Path") { ApplicationArea = All; }
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
                    ObjGen.DownloadAsMDDosFile(ObjGen.CreateNAV2009Dataport(Rec."Object ID Dataport (Export)"), 'DAMExport.txt');
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
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertWhenEmpty();
    end;
}