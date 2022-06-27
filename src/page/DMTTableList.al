page 81133 "DMTTableList"
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
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; BlankZero = true; }
                field("NAV Src.Table No."; Rec."NAV Src.Table No.") { ApplicationArea = All; Visible = false; }
                field("From Table Caption"; Rec."NAV Src.Table Caption") { ApplicationArea = All; Visible = false; }
                field("To Table ID"; Rec."To Table ID") { ApplicationArea = All; Visible = false; }
                field("To Table Caption"; Rec."Dest.Table Caption") { ApplicationArea = All; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; StyleExpr = BufferTableIDStyle; }
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { ApplicationArea = All; StyleExpr = ImportXMLPortIDStyle; }
                field(ExportFilePath; Rec.DataFilePath) { ApplicationArea = All; }
                field(BufferTableType; BufferTableType) { ApplicationArea = All; Visible = false; }
                field("Data Source Type"; "Data Source Type") { ApplicationArea = All; Visible = false; }
                field(LastImportBy; Rec.LastImportBy) { ApplicationArea = All; Visible = false; }
                field(LastImportToTargetAt; Rec.LastImportToTargetAt) { ApplicationArea = All; }
                field("Qty.Lines In Src. Table"; Rec."No.of Records in Buffer Table") { ApplicationArea = All; }
                field("Qty.Lines In Trgt. Table"; GetNoOfRecordsInTrgtTable(Rec))
                {
                    ApplicationArea = All;
                    Caption = 'Qty.Lines In Trgt. Table', Comment = 'Anz. Datensätze in Zieltabelle';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.ShowTableContent(Rec."To Table ID");
                    end;
                }
                field("Import Duration (Longest)"; Rec."Import Duration (Longest)") { ApplicationArea = All; }
            }
        }
        area(FactBoxes)
        {
            part(DMTTableFactBox; DMTTableFactBox)
            {
                SubPageLink = "To Table ID" = field("To Table ID");
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
                Caption = 'Read all files into buffer tables', Comment = 'Alle Dateien in Puffertabellen einlesen';
                ApplicationArea = all;
                trigger OnAction()
                var
                    DMTTable: Record DMTTable;
                    Progress: Dialog;
                    Start: DateTime;
                    ImportFilesProgressMsg: Label 'Reading files into buffer tables\ Table: ############1#', Comment = 'Dateien werden eingelesen\ Tabelle: ############1#';
                    FinishedMsg: Label 'Processing finished\Duration %1', Comment = 'Vorgang abgeschlossen\Dauer %1';
                begin
                    if DMTTable.FindSet() then begin
                        Start := CurrentDateTime;
                        Progress.Open(ImportFilesProgressMsg);
                                                   repeat
                                                       Progress.Update(1, DMTTable."Dest.Table Caption");
                                                       DMTTable.ImportToBufferTable();
                                                   until DMTTable.Next() = 0;
                        Progress.Close();
                        Message(FinishedMsg, CurrentDateTime - Start);
                    end;
                end;
            }
            action(ExportALObjects)
            {
                Image = ExportFile;
                ApplicationArea = all;
                Caption = 'Download buffer table objects', Comment = 'Puffertabellen Objekte runterladen';
                trigger OnAction()
                var
                    DMTTable: Record DMTTable;
                begin
                    if DMTTable.FindSet() then
                        repeat
                                DMTTable.DownloadAllALDataMigrationObjects(Rec);
                        until DMTTable.Next() = 0;
                end;
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
        }
    }

    procedure GetSelection(var DMTTable_SELECTED: Record DMTTable) HasLines: Boolean
    begin
        Clear(DMTTable_SELECTED);
        CurrPage.SetSelectionFilter(DMTTable_SELECTED);
        HasLines := DMTTable_SELECTED.FindFirst();
    end;

    local procedure GetNoOfRecordsInTrgtTable(DMTTable: Record DMTTable): Integer
    var
        TableInformation: Record "Table Information";
    begin
        if TableInformation.Get(CompanyName, DMTTable."To Table ID") then;
        // TableInformation.Calcfields("No. of Records");
        exit(TableInformation."No. of Records");
    end;

    trigger OnAfterGetRecord()
    var
        AllObj: Record AllObjWithCaption;
    begin
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
        Rec.TryFindExportDataFile();
    end;

    var
        [InDataSet]
        ImportXMLPortIDStyle: Text;
        [InDataSet]
        BufferTableIDStyle: Text;
}