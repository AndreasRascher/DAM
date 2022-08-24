page 50014 "DMTTableList"
{
    Caption = 'DMT Table List', comment = 'DMT Tabellenübersicht';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTTable;
    CardPageId = DMTTableCard;
    SourceTableView = sorting("Sort Order");
    DelayedInsert = true;
    // Editable = false;

    layout
    {
        area(Content)
        {
            repeater(DMTTableRepeater)
            {
                FreezeColumn = "To Table Caption";
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; BlankZero = true; }
                field("From Table Caption"; Rec."NAV Src.Table Caption") { ApplicationArea = All; Visible = false; Editable = false; }
                field("To Table Caption"; Rec."Target Table Caption") { ApplicationArea = All; Editable = false; }
                field("NAV Src.Table No."; Rec."NAV Src.Table No.") { ApplicationArea = All; Visible = false; }
                field("To Table ID"; Rec."Target Table ID") { ApplicationArea = All; Visible = false; Editable = false; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; StyleExpr = BufferTableIDStyle; }
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { ApplicationArea = All; StyleExpr = ImportXMLPortIDStyle; }
                field(ExportFileFolderPath; Rec.DataFileFolderPath) { ApplicationArea = All; StyleExpr = DataFilePathStyle; }
                field(ExportFileName; Rec.DataFileName) { ApplicationArea = All; StyleExpr = DataFilePathStyle; }
                field(BufferTableType; Rec.BufferTableType) { ApplicationArea = All; Visible = false; }
                field("Data Source Type"; Rec."Data Source Type") { ApplicationArea = All; Visible = false; }
                field(LastImportBy; Rec.LastImportBy) { ApplicationArea = All; Visible = false; Editable = false; }
                field(LastImportToBufferAt; Rec.LastImportToBufferAt) { ApplicationArea = All; Editable = false; }
                field(LastImportToTargetAt; Rec.LastImportToTargetAt) { ApplicationArea = All; Editable = false; }
                field("Qty.Lines In Src. Table"; Rec."No.of Records in Buffer Table") { ApplicationArea = All; Editable = false; }
                field("Qty.Lines In Trgt. Table"; Rec.GetNoOfRecordsInTrgtTable())
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Qty.Lines In Trgt. Table', Comment = 'Anz. Datensätze in Zieltabelle';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.ShowTableContent(Rec."Target Table ID");
                    end;
                }
                field("Import Duration (Longest)"; Rec."Import Duration (Longest)") { ApplicationArea = All; Editable = false; }
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
        area(FactBoxes)
        {
            part(DMTTableFactBox; DMTTableFactBox)
            {
                SubPageLink = "Target Table ID" = field("Target Table ID");
                Visible = false;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SelectTablesToAdd)
            {
                Caption = 'Add Tables', Comment = 'Tab. hinzufügen';
                Image = Add;
                ApplicationArea = all;
                trigger OnAction()
                var
                    ObjMgt: Codeunit DMTObjMgt;
                begin
                    ObjMgt.AddSelectedTables();
                end;
            }
            action(ImportBufferTables)
            {
                Image = ImportDatabase;
                Caption = 'Read files into buffer tables (marked lines)', Comment = 'Dateien in Puffertabellen einlesen (markierte Zeilen)';
                ApplicationArea = all;
                trigger OnAction()
                var
                    DMTTable, DMTTable_SELECTED : Record DMTTable;
                    Progress: Dialog;
                    Start, TableStart : DateTime;
                    ImportFilesProgressMsg: Label 'Reading files into buffer tables', Comment = 'Dateien werden eingelesen';
                    ProgressMsg: Text;
                    FinishedMsg: Label 'Processing finished\Duration %1', Comment = 'Vorgang abgeschlossen\Dauer %1';
                begin
                    DMTTable_SELECTED.SetCurrentKey("Sort Order");
                    if not GetSelection(DMTTable_SELECTED) then
                        exit;
                    ProgressMsg := '==========================================\' +
                                   ImportFilesProgressMsg + '\' +
                                   '==========================================\';

                    DMTTable_SELECTED.FindSet(false, false);
                    REPEAT
                        ProgressMsg += '\' + DMTTable_SELECTED."Target Table Caption" + '    ###########################' + FORMAT(DMTTable_SELECTED."Target Table ID") + '#';
                    UNTIL DMTTable_SELECTED.NEXT() = 0;

                    DMTTable_SELECTED.FindSet();
                    Start := CurrentDateTime;
                    Progress.Open(ProgressMsg);
                    repeat
                        TableStart := CurrentDateTime;
                        DMTTable := DMTTable_SELECTED;
                        Progress.Update(DMTTable_SELECTED."Target Table ID", 'Wird eingelesen');
                        DMTTable.ImportToBufferTable();
                        Commit();
                        Progress.Update(DMTTable_SELECTED."Target Table ID", CURRENTDATETIME - TableStart);
                    until DMTTable_SELECTED.Next() = 0;
                    Progress.Close();
                    Message(FinishedMsg, CurrentDateTime - Start);
                end;
            }
            group(Objects)
            {
                Image = Action;
                action(ExportALObjects)
                {
                    Image = ExportFile;
                    ApplicationArea = all;
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

            action(TransferSelectedToTargetTable)
            {
                Image = TransferToLines;
                ApplicationArea = all;
                Caption = 'Import to target tables (marked lines)', comment = 'In Zieltabellen übernehmen (Markierte Zeilen)';
                trigger OnAction()
                var
                    DMTTable: Record DMTTable;
                    DMTTable_SELECTED: Record DMTTable;
                    DMTImport: Codeunit "DMTImport";
                begin
                    DMTTable_SELECTED.SetCurrentKey("Sort Order");
                    if not GetSelection(DMTTable_SELECTED) then
                        exit;
                    DMTTable_SELECTED.FindSet();
                    repeat
                        DMTTable := DMTTable_SELECTED;
                        DMTImport.StartImport(DMTTable, true, false);
                    until DMTTable_SELECTED.Next() = 0;
                end;
            }
            action("Task")
            {
                Caption = 'Task';
                Promoted = true;
                PromotedCategory = New;
                ApplicationArea = All;
                trigger OnAction()
                var
                    MyDictionary: Dictionary of [Text, Text];
                begin
                    MyDictionary.Add('Param1', 'Value1');
                    MyTaskId := 1;
                    CurrPage.EnqueueBackgroundTask(MyTaskId, Codeunit::DMTPageBackgroundTasks);
                end;
            }
        }
    }

    procedure GetSelection(var DMTTable_SELECTED: Record DMTTable) HasLines: Boolean
    begin
        Clear(DMTTable_SELECTED);
        CurrPage.SetSelectionFilter(DMTTable_SELECTED);
        HasLines := DMTTable_SELECTED.FindFirst();
    end;

    trigger OnOpenPage()
    var
        PageTaskID: Integer;
        Params: Dictionary of [Text, Text];
    begin
        // CurrPage.EnqueueBackgroundTask(PageTaskID, Codeunit::DMTPageBackgroundTasks, Params, 60 * 2, PageBackgroundTaskErrorLevel::Error);
    end;

    trigger OnAfterGetRecord()
    var
        AllObj: Record AllObjWithCaption;
    begin
        ImportXMLPortIDStyle := 'Unfavorable';
        BufferTableIDStyle := 'Unfavorable';
        DataFilePathStyle := 'Unfavorable';
        if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then begin
            clear(ImportXMLPortIDStyle);
            clear(BufferTableIDStyle);
        end;
        if AllObj.Get(AllObj."Object Type"::XMLport, Rec."Import XMLPort ID") then
            ImportXMLPortIDStyle := 'Favorable';
        if AllObj.Get(AllObj."Object Type"::Table, Rec."Buffer Table ID") then
            BufferTableIDStyle := 'Favorable';
        if Rec.TryFindExportDataFile() then
            DataFilePathStyle := 'Favorable';

    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        DMTTable: Record DMTTable;
        RecID: RecordId;
        NoOfTableRelations: Integer;
        RecIDAsText: Text;
    begin
        foreach RecIDAsText in Results.Keys do begin
            Evaluate(RecID, RecIDAsText);
            Evaluate(NoOfTableRelations, Results.Get(RecIDAsText));
            DMTTable.get(RecID);
            if DMTTable."Table Relations" <> NoOfTableRelations then begin
                DMTTable."Table Relations" := NoOfTableRelations;
                DMTTable.Modify();
            end;
        end;
        CurrPage.Update();
        Message('ok for task: %1', TaskId);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        Message('not ok for task: %1', TaskId);
    end;

    var
        [InDataSet]
        ImportXMLPortIDStyle, BufferTableIDStyle, DataFilePathStyle : Text;
        MyTaskId: Integer;

}