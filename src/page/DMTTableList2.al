page 110025 "DMTTableList2"
{
    Caption = 'DMT Table List 2', comment = 'DMT Tabellenübersicht 2';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTTable;
    DataCaptionFields = "Target Table ID";
    // CardPageId = DMTTableCard;
    SourceTableView = sorting("Sort Order");
    DelayedInsert = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PromotedActionCategoriesML = ENU = '1,2,3,Lines,Objects,View', DEU = '1,2,3,Zeilen,Objekte,Ansicht';
    // Editable = false;

    layout
    {
        area(Content)
        {
            repeater(SetupView)
            {
                Visible = SetupViewActive;
                field("Target Table ID"; Rec."Target Table ID")
                {
                    ApplicationArea = All;
                    Caption = 'Zieltab. ID';
                    trigger OnDrillDown()
                    begin
                        Rec.OpenCardPage();
                    end;
                }
                field("Target Table Caption"; Rec."Target Table Caption") { ApplicationArea = All; }
                field(Folder; Rec.DataFileFolderPath) { ApplicationArea = All; }
                field(FileName; Rec.DataFileName) { ApplicationArea = All; }
                field("Import XMLPort ID"; rec."Import XMLPort ID") { ApplicationArea = All; }
                field(BufferTableType; rec.BufferTableType) { ApplicationArea = All; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; }
                field("No.of Src.Fields Assigned"; Rec."No.of Src.Fields Assigned") { ApplicationArea = All; }
            }
            repeater(ImportView)
            {
                Visible = not SetupViewActive;
                field(FileName_ImportView; Rec.DataFileName)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        Rec.OpenCardPage();
                    end;
                }
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
                field("Import Duration (Longest)"; Rec."Import Duration (Longest)") { ApplicationArea = All; }
                field(LastImportBy; Rec.LastImportBy) { ApplicationArea = All; Visible = false; }
                field(LastImportToBufferAt; Rec.LastImportToBufferAt) { ApplicationArea = All; }
                field(LastImportToTargetAt; Rec.LastImportToTargetAt) { ApplicationArea = All; }
                field(ImportToBufferIndicator; ImportToBufferIndicator)
                {
                    ApplicationArea = All;
                    StyleExpr = ImportToBufferIndicatorStyle;
                    Caption = 'Buffer Import';
                }
                field(ImportToTargetIndicator; ImportToTargetIndicator)
                {
                    ApplicationArea = All;
                    StyleExpr = ImportToTargetIndicatorStyle;
                    Caption = 'Target Import';
                }
                field("No.of Records in Buffer Table"; Rec."No.of Records in Buffer Table") { ApplicationArea = All; }
                field("No. of Lines In Trgt. Table"; Rec."No. of Lines In Trgt. Table") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            group(MarkedLines)
            {
                Image = AllLines;
                action(SelectTablesToAdd)
                {
                    Caption = 'Add Tables', Comment = 'Tab. hinzufügen';
                    Image = Add;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category4;
                    trigger OnAction()
                    var
                        ObjMgt: Codeunit DMTObjMgt;
                    begin
                        ObjMgt.AddSelectedTables();
                    end;
                }
                action(SelectTablesToAdd2)
                {
                    Caption = 'Add Tables2', Comment = 'Tab. hinzufügen';
                    Image = Add;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category4;
                    trigger OnAction()
                    var
                        ObjMgt: Codeunit DMTObjMgt;
                    begin
                        ObjMgt.AddSelectedTables();
                    end;
                }


            }
            group(Objects)
            {
                Image = Action;
                action(ExportALObjects)
                {
                    Image = ExportFile;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Caption = 'Download buffer table objects', Comment = 'Puffertabellen Objekte runterladen';
                    trigger OnAction()
                    begin
                        Rec.DownloadAllALDataMigrationObjects();
                    end;
                }
                action(RenumberALObjects)
                {
                    Image = NumberGroup;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Caption = 'Renumber AL Objects', Comment = 'AL Objekte neu Nummerieren';
                    trigger OnAction()
                    begin
                        Rec.RenumberALObjects();
                    end;
                }
                action(RenewObjectIdAssignments)
                {
                    Image = NumberGroup;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Caption = 'Renew object id assignments', Comment = 'Objekt-IDs neu zuordnen';
                    trigger OnAction()
                    begin
                        Rec.RenewObjectIdAssignments();
                    end;
                }
                action(GetToTableIDFilter)
                {
                    Image = FilterLines;
                    Caption = 'To Table ID Filter', Comment = 'Zieltabellen-ID Filter';
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category5;
                    trigger OnAction()
                    begin
                        Message(Rec.CreateTableIDFilter(Rec.FieldNo("Target Table ID")));
                    end;
                }
                action(GetFromTableIDFilter)
                {
                    Image = FilterLines;
                    Caption = 'From Table ID Filter', Comment = 'Herkunftstabellen-ID Filter';
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category5;
                    trigger OnAction()
                    begin
                        Message(Rec.CreateTableIDFilter(Rec.FieldNo("NAV Src.Table No.")));
                    end;
                }
            }
            action(ActivateSetupView)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Visible = not SetupViewActive;
                Caption = 'Zu Einrichtungsansicht wechseln';
                trigger OnAction()
                begin
                    SetupViewActive := not SetupViewActive;
                    CurrPage.Update();
                end;
            }
            action(ActivateImportView)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Visible = SetupViewActive;
                Caption = 'Zu Importansicht wechseln';
                trigger OnAction()
                begin
                    SetupViewActive := not SetupViewActive;
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateIndicators();
    end;

    trigger OnOpenPage()
    var
        DMTSetup: Record DMTSetup;
    begin
        DMTSetup.InsertWhenEmpty();
    end;

    local procedure UpdateIndicators()
    begin
        /* Import To Buffer */
        ImportToBufferIndicatorStyle := Format(Enum::DMTFieldStyle::None);
        ImportToBufferIndicator := ' ';
        case true of
            (Rec."No.of Records in Buffer Table" = 0):
                begin
                    ImportToBufferIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
                    ImportToBufferIndicator := '✘';
                end;
            (Rec."No.of Records in Buffer Table" > 0):
                begin
                    ImportToBufferIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
                    ImportToBufferIndicator := '✔';
                end;
        end;
        /* Import To Target */
        ImportToTargetIndicatorStyle := Format(Enum::DMTFieldStyle::None);
        ImportToTargetIndicator := ' ';
        case true of
            (Rec.LastImportToTargetAt = 0DT) or (Rec."No.of Records in Buffer Table" > Rec."No. of Lines In Trgt. Table"):
                begin
                    ImportToTargetIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
                    ImportToTargetIndicator := '✘';
                end;
            (Rec.LastImportToTargetAt <> 0DT) and (Rec."No.of Records in Buffer Table" <= Rec."No. of Lines In Trgt. Table"):
                begin
                    ImportToTargetIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
                    ImportToTargetIndicator := '✔';
                end;
        end;
    end;

    var
        [InDataSet]
        SetupViewActive: Boolean;
        ImportToBufferIndicatorStyle, ImportToTargetIndicatorStyle : Text;
        ImportToBufferIndicator, ImportToTargetIndicator : Char;
}
