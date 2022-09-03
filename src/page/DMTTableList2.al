page 110014 "DMTTableList"
{
    Caption = 'DMT Table List', comment = 'DMT Tabellenübersicht';
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
    PromotedActionCategoriesML = ENU = '1,2,3,Tables,Objects,Migration', DEU = '1,2,3,Tabellen,Objekte,Migration';
    RefreshOnActivate = true;
    // Editable = false;

    layout
    {
        area(Content)
        {
            repeater(SetupView)
            {
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
                field("Target Table ID"; Rec."Target Table ID")
                {
                    ApplicationArea = All;
                    Caption = 'Source Table ID', Comment = 'Zieltab. ID';
                    Editable = false; // LookUp
                    trigger OnDrillDown()
                    begin
                        Commit();
                        Rec.OpenCardPage();
                        if Rec.get(Rec.RecordId) then;  //Delete from Card Page
                    end;
                }
                field("Target Table Caption"; Rec."Target Table Caption") { ApplicationArea = All; }
                field(Folder; Rec.DataFileFolderPath) { ApplicationArea = All; Visible = false; }
                field(FileName; Rec.DataFileName)
                {
                    ApplicationArea = All;
                    StyleExpr = Rec.DataFilePathStyle;
                    // trigger OnDrillDown()
                    // begin
                    //     Rec.OpenCardPage();
                    // end;
                }
                field(BufferTableType; rec.BufferTableType) { ApplicationArea = All; }
                field("Import XMLPort ID"; rec."Import XMLPort ID") { ApplicationArea = All; StyleExpr = ImportXMLPortIDStyle; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; StyleExpr = BufferTableIDStyle; }
                field("No.of Src.Fields Assigned"; Rec."No.of Src.Fields Assigned") { ApplicationArea = All; }
                field("Import Duration (Longest)"; Rec."Import Duration (Longest)") { ApplicationArea = All; }
                field(LastImportBy; Rec.LastImportBy) { ApplicationArea = All; Visible = false; }
                field(LastImportToBufferAt; Rec.LastImportToBufferAt) { ApplicationArea = All; }
                field(LastImportToTargetAt; Rec.LastImportToTargetAt) { ApplicationArea = All; }
                field(ImportToBufferIndicator; ImportToBufferIndicator) { ApplicationArea = All; Caption = 'Buffer Import'; StyleExpr = ImportToBufferIndicatorStyle; }
                field(ImportToTargetIndicator; ImportToTargetIndicator) { ApplicationArea = All; Caption = 'Target Import'; StyleExpr = ImportToTargetIndicatorStyle; }
                field("No.of Records in Buffer Table"; Rec."No.of Records in Buffer Table") { ApplicationArea = All; }
                field("No. of Lines In Trgt. Table"; Rec."No. of Lines In Trgt. Table") { ApplicationArea = All; }
                field("No. of Table Relations"; rec."Table Relations")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        RelationsCheck: Codeunit DMTRelationsCheck;
                    begin
                        RelationsCheck.ShowTableRelations(Rec);
                    end;
                }
                field("Unhandled Table Rel."; "Unhandled Table Rel.")
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
        area(Processing)
        {
            #region Tabellen
            action(SelectTablesToAdd)
            {
                Caption = 'Add Tables', Comment = 'Tab. hinzufügen';
                Image = Add;
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                trigger OnAction()
                var
                    DMTSetup: Record DMTSetup;
                begin
                    if Rec."Target Table ID" <> 0 then
                        CurrPage.SaveRecord();
                    DMTSetup.CheckSchemaInfoHasBeenImporterd();
                    Commit();
                    PageActions.AddSelectedTargetTables();
                end;
            }
            action(DeleteMarkedLines)
            {
                Caption = 'Delete Marked Lines', Comment = 'Markierte Zeilen löschen';
                Image = DeleteRow;
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    GetSelection(TempDMTTable_SELECTED);
                    PageActions.DeleteSelectedTargetTables(TempDMTTable_SELECTED);
                end;
            }
            #endregion Tabellen

            #region Objekte
            action(ExportALObjects)
            {
                Image = ExportFile;
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category5;
                Caption = 'Download buffer table objects', Comment = 'Puffertabellen Objekte runterladen';
                trigger OnAction()
                begin
                    PageActions.DownloadAllALDataMigrationObjects();
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
                    PageActions.RenewObjectIdAssignments();
                end;
            }
            #endregion Objekte

            #region Migration
            action(ImportSelectedToBuffer)
            {
                Image = ImportDatabase;
                Caption = 'Read files into buffer tables (marked lines)', Comment = 'Dateien in Puffertabellen einlesen (markierte Zeilen)';
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    GetSelection(TempDMTTable_SELECTED);
                    PageActions.ImportSelectedIntoBuffer(TempDMTTable_SELECTED);
                end;
            }
            action(ProposeMatchingFields)
            {
                Caption = 'Popose Matching Fields', comment = 'Feldzuordnung vorschlagen';
                ApplicationArea = All;
                Image = SuggestField;
                trigger OnAction()
                begin
                    GetSelection(TempDMTTable_SELECTED);
                    PageActions.ProposeMatchingFieldsForSelection(TempDMTTable_SELECTED);
                end;
            }
            action(ImportSelectedToTarget)
            {
                Image = TransferToLines;
                ApplicationArea = all;
                Caption = 'Import to target tables (marked lines)', comment = 'In Zieltabellen übernehmen (Markierte Zeilen)';
                trigger OnAction()
                begin
                    GetSelection(TempDMTTable_SELECTED);
                    PageActions.ImportSelectedIntoTarget(TempDMTTable_SELECTED);
                end;
            }
            #endregion Migration

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
                            DMTTable."Unhandled Table Rel." := RelationsCheck.FindUnhandledRelatedTableIDs(DMTTable).Count;
                            DMTTable.Modify();
                        until DMTTable.Next() = 0;
                end;
            }
            action(UpdateSortOrder)
            {
                Image = BulletList;
                ApplicationArea = All;
                Caption = 'Update Sort Order', Comment = 'Update der Sortierung';
                trigger OnAction()
                var
                    RelationsCheck: Codeunit DMTRelationsCheck;
                begin
                    RelationsCheck.ProposeSortOrder();
                end;
            }

            action(GetToTableIDFilter)
            {
                Image = FilterLines;
                Caption = 'To Table ID Filter', Comment = 'Zieltabellen-ID Filter';
                ApplicationArea = all;
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
                trigger OnAction()
                begin
                    Message(Rec.CreateTableIDFilter(Rec.FieldNo("NAV Src.Table No.")));
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
        Rec.TryFindExportDataFile(false);
    end;

    trigger OnOpenPage()
    var
        DMTSetup: Record DMTSetup;
    begin
        Rec.SetDefaultFilters();
        DMTSetup.InsertWhenEmpty();
    end;

    procedure GetSelection(var DMTTable_Selected: Record DMTTable temporary) HasLines: Boolean
    var
        DMTTable: Record DMTTable;
    begin
        Clear(DMTTable_Selected);
        if DMTTable_Selected.IsTemporary then
            DMTTable_Selected.DeleteAll();
        DMTTable.Copy(rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(DMTTable);
        DMTTable.CopyToTemp(DMTTable_Selected);
        HasLines := DMTTable_Selected.FindFirst();
    end;

    var
        TempDMTTable_SELECTED: Record DMTTable temporary;
        PageActions: Codeunit DMTPageActions;
}
