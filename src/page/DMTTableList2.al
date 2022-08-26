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
                field("Import XMLPort ID"; rec."Import XMLPort ID") { ApplicationArea = All; StyleExpr = ImportXMLPortIDStyle; }
                field(BufferTableType; rec.BufferTableType) { ApplicationArea = All; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; StyleExpr = BufferTableIDStyle; }
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
                field(ImportToBufferIndicator; ImportToBufferIndicator) { ApplicationArea = All; Caption = 'Buffer Import'; StyleExpr = ImportToBufferIndicatorStyle; }
                field(ImportToTargetIndicator; ImportToTargetIndicator) { ApplicationArea = All; Caption = 'Target Import'; StyleExpr = ImportToTargetIndicatorStyle; }
                field("No.of Records in Buffer Table"; Rec."No.of Records in Buffer Table") { ApplicationArea = All; }
                field("No. of Lines In Trgt. Table"; Rec."No. of Lines In Trgt. Table") { ApplicationArea = All; }
                field("No. of Unhandled Table Relations"; rec."Table Relations")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        RelationsCheck: Codeunit DMTRelationsCheck;
                    begin
                        RelationsCheck.ShowUnhandledTableRelations(Rec);
                    end;
                }
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
                    Visible = SetupViewActive;
                    Caption = 'Add Tables', Comment = 'Tab. hinzufügen';
                    Image = Add;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        ObjMgt: Codeunit DMTObjMgt;
                    begin
                        ObjMgt.AddSelectedTables();
                    end;
                }
                action(DeleteMarkedLines)
                {
                    Visible = SetupViewActive;
                    Caption = 'Delete Marked Lines', Comment = 'Markiert Zeilen löschen';
                    Image = DeleteRow;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        DMTTable: Record DMTTable;
                    begin
                        if GetSelection(DMTTable) then
                            DMTTable.DeleteAll(true);
                    end;
                }
                action(ImportBufferTables)
                {
                    Visible = not SetupViewActive;
                    Image = ImportDatabase;
                    Caption = 'Read files into buffer tables (marked lines)', Comment = 'Dateien in Puffertabellen einlesen (markierte Zeilen)';
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        DMTTable_SELECTED: Record DMTTable;
                    begin
                        if GetSelection(DMTTable_SELECTED) then
                            Rec.ImportSelectedIntoBuffer(DMTTable_SELECTED);
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
                action(UpdateTableRelationInfo)
                {
                    Image = Relationship;
                    ApplicationArea = All;
                    Caption = 'Update Missing Table Relations', Comment = 'Update der offenen Tabellenrelationen';
                    trigger OnAction()
                    var
                        DMTTable: Record DMTTable;
                        RelationsCheck: Codeunit DMTRelationsCheck;
                    begin
                        if DMTTable.FindSet() then
                            repeat
                                DMTTable."Table Relations" := RelationsCheck.FindRelatedTableIDs(DMTTable).Count;
                                DMTTable.Modify();
                            until DMTTable.Next() = 0;
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
    views
    {
        view(BufferTableTypeSeperate)
        {
            Caption = 'Seperate Buffer Table per CSV', Comment = 'Leere Puffertab.';
            Filters = where(BufferTableType = const("Seperate Buffer Table per CSV"));
        }
        view(BufferTableTypeGeneric)
        {
            Caption = 'Generic Buffer Table for all Files', Comment = 'Gen. Puffertab.';
            Filters = where(BufferTableType = const("Generic Buffer Table for all Files"));
        }
        view(EmptyBuffer)
        {
            Caption = 'Empty Buffer Table', Comment = 'Leere Puffertab.';
            Filters = where("No.of Records in Buffer Table" = const(0));
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateIndicators();
        Rec.TryFindExportDataFile();
    end;

    trigger OnOpenPage()
    var
        DMTSetup: Record DMTSetup;
    begin
        DMTSetup.InsertWhenEmpty();
    end;

    local procedure UpdateIndicators()
    var
        AllObj: Record AllObjWithCaption;
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


        ImportXMLPortIDStyle := 'Unfavorable';
        BufferTableIDStyle := 'Unfavorable';
        if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then begin
            clear(ImportXMLPortIDStyle);
            clear(BufferTableIDStyle);
        end;
        if AllObj.Get(AllObj."Object Type"::XMLport, Rec."Import XMLPort ID") then
            ImportXMLPortIDStyle := 'Favorable';
        if AllObj.Get(AllObj."Object Type"::Table, Rec."Buffer Table ID") then
            BufferTableIDStyle := 'Favorable';
    end;

    procedure GetSelection(var DMTTable_SELECTED: Record DMTTable) HasLines: Boolean
    begin
        Clear(DMTTable_SELECTED);
        CurrPage.SetSelectionFilter(DMTTable_SELECTED);
        HasLines := DMTTable_SELECTED.FindFirst();
    end;

    var
        [InDataSet]
        SetupViewActive: Boolean;
        ImportToBufferIndicatorStyle, ImportToTargetIndicatorStyle : Text;
        ImportXMLPortIDStyle, BufferTableIDStyle : Text;
        ImportToBufferIndicator, ImportToTargetIndicator : Char;
}
