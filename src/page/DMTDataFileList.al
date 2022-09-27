page 110027 "DMTDataFileList"
{
    Caption = 'DMT Data File List';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTDataFile;
    SourceTableView = sorting("Sort Order", "Target Table ID");
    CardPageId = DMTDataFileCard;
    PromotedActionCategoriesML = ENU = '1,2,3,Tables,Objects,Migration,Files', DEU = '1,2,3,Tabellen,Objekte,Migration,Dateien';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                FreezeColumn = "Target Table ID";
                field("Target Table ID"; Rec."Target Table ID") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
                field(ID; Rec.ID) { ApplicationArea = All; Visible = false; }
                field(Size; Rec.Size) { ApplicationArea = All; }
                field("Created At"; Rec."Created At") { ApplicationArea = All; }
                field(BufferTableType; Rec.BufferTableType) { ApplicationArea = All; }
                field("Table Relations"; Rec."Table Relations") { ApplicationArea = All; }
                field("Import XMLPort ID"; rec."Import XMLPort ID") { ApplicationArea = All; StyleExpr = Rec.ImportXMLPortIDStyle; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; StyleExpr = Rec.BufferTableIDStyle; }
                // field("No.of Src.Fields Assigned"; Rec."No.of Src.Fields Assigned") { ApplicationArea = All; }
                field("Import Duration (Buffer)"; Rec."Import Duration (Buffer)") { ApplicationArea = All; }
                field("Import Duration (Target)"; Rec."Import Duration (Target)") { ApplicationArea = All; }
                field(LastImportBy; Rec.LastImportBy) { ApplicationArea = All; Visible = false; }
                field(LastImportToBufferAt; Rec.LastImportToBufferAt) { ApplicationArea = All; }
                field(LastImportToTargetAt; Rec.LastImportToTargetAt) { ApplicationArea = All; }
                field(ImportToBufferIndicator; Rec.ImportToBufferIndicator) { ApplicationArea = All; Caption = 'Buffer Import'; StyleExpr = Rec.ImportToBufferIndicatorStyle; }
                field(ImportToTargetIndicator; Rec.ImportToTargetIndicator) { ApplicationArea = All; Caption = 'Target Import'; StyleExpr = Rec.ImportToTargetIndicatorStyle; }
                field("No.of Records in Buffer Table"; Rec."No.of Records in Buffer Table") { ApplicationArea = All; }
                field("No. of Lines In Trgt. Table"; Rec."No. of Records In Trgt. Table") { ApplicationArea = All; }
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
            // action(SelectTablesToAdd)
            // {
            //     Caption = 'Add Tables', Comment = 'Tab. hinzufügen';
            //     Image = Add;
            //     ApplicationArea = all;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedOnly = true;
            //     trigger OnAction()
            //     var
            //         DMTSetup: Record DMTSetup;
            //     begin
            //         if Rec."Target Table ID" <> 0 then
            //             CurrPage.SaveRecord();
            //         Commit();
            //         DMTSetup.CheckSchemaInfoHasBeenImporterd();
            //         PageActions.AddSelectedTargetTables();
            //     end;
            // }
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
                    PageActions.RenumberALObjects();
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
                    GetSelection(TempDataFile_SELECTED);
                    PageActions.ImportSelectedIntoBuffer(TempDataFile_SELECTED);
                end;
            }
            action(ProposeMatchingFields)
            {
                Caption = 'Popose Matching Fields', comment = 'Feldzuordnung vorschlagen';
                ApplicationArea = All;
                Image = SuggestField;
                trigger OnAction()
                begin
                    GetSelection(TempDataFile_SELECTED);
                    PageActions.ProposeMatchingFieldsForSelection(TempDataFile_SELECTED);
                end;
            }
            action(ImportSelectedToTarget)
            {
                Image = TransferToLines;
                ApplicationArea = all;
                Caption = 'Import to target tables (marked lines)', comment = 'In Zieltabellen übernehmen (Markierte Zeilen)';
                trigger OnAction()
                begin
                    GetSelection(TempDataFile_SELECTED);
                    PageActions.ImportSelectedIntoTarget(TempDataFile_SELECTED);
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
                    DataFile: Record DMTDataFile;
                    RelationsCheck: Codeunit DMTRelationsCheck;
                begin
                    if DataFile.FindSet() then
                        repeat
                            DataFile."Table Relations" := RelationsCheck.FindRelatedTableIDs(DataFile).Count;
                            DataFile."Unhandled Table Rel." := RelationsCheck.FindUnhandledRelatedTableIDs(DataFile).Count;
                            DataFile.Modify();
                        until DataFile.Next() = 0;
                end;
            }
            // action(UpdateSortOrder)
            // {
            //     Image = BulletList;
            //     ApplicationArea = All;
            //     Caption = 'Update Sort Order', Comment = 'Update der Sortierung';
            //     trigger OnAction()
            //     var
            //         RelationsCheck: Codeunit DMTRelationsCheck;
            //     begin
            //         RelationsCheck.ProposeSortOrder();
            //     end;
            // }

            action(GetToTableIDFilter)
            {
                Image = FilterLines;
                Caption = 'To Table ID Filter', Comment = 'Zieltabellen-ID Filter';
                ApplicationArea = all;
                trigger OnAction()
                begin
                    Message(PageActions.CreateTableIDFilter(Rec.FieldNo("Target Table ID")));
                end;
            }
            action(GetFromTableIDFilter)
            {
                Image = FilterLines;
                Caption = 'From Table ID Filter', Comment = 'Herkunftstabellen-ID Filter';
                ApplicationArea = all;
                trigger OnAction()
                begin
                    Message(PageActions.CreateTableIDFilter(Rec.FieldNo("NAV Src.Table No.")));
                end;
            }
            action(AddDataFile)
            {
                Image = Add;
                Caption = 'Add Data File';
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category7;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    PageActions.AddDataFiles();
                end;
            }
            action(DeleteMarkedLines)
            {
                Caption = 'Delete Marked Lines', Comment = 'Markierte Zeilen löschen';
                Image = DeleteRow;
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category7;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    GetSelection(TempDataFile_SELECTED);
                    PageActions.DeleteSelectedTargetTables(TempDataFile_SELECTED);
                end;
            }
        }
    }
    procedure GetSelection(var DataFile_Selected: Record DMTDataFile temporary) HasLines: Boolean
    var
        DataFile: Record DMTDataFile;
    begin
        Clear(DataFile_Selected);
        if DataFile_Selected.IsTemporary then
            DataFile_Selected.DeleteAll();
        DataFile.Copy(rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(DataFile);
        DataFile.CopyToTemp(DataFile_Selected);
        HasLines := DataFile_Selected.FindFirst();
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.UpdateIndicators();
        // ImportToBufferIndicatorStyleTxt := Rec.ImportToBufferIndicatorStyle;
        // ImportToTargetIndicatorStyleTxt := Rec.ImportToTargetIndicatorStyle;
    end;

    var
        TempDataFile_SELECTED: record DMTDataFile temporary;
        PageActions: Codeunit DMTDataFilePageAction;
    // ImportToBufferIndicatorStyleTxt, ImportToTargetIndicatorStyleTxt : Text[15];
}