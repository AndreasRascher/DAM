page 91004 "DAMTableList"
{
    CaptionML = DEU = 'DAM Tabellenübersicht', ENU = 'DAM Table List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DAMTable;
    CardPageId = DAMTableCard;
    SourceTableView = sorting("Sort Order");

    layout
    {
        area(Content)
        {
            repeater(DAMTableRepeater)
            {
                field("Sort Order"; rec."Sort Order") { ApplicationArea = All; BlankZero = true; }
                field("Old Version Table ID"; Rec."Old Version Table ID") { ApplicationArea = All; Visible = false; }
                field("From Table Caption"; Rec."Old Version Table Caption") { ApplicationArea = All; }
                field("To Table ID"; Rec."To Table ID") { ApplicationArea = All; Visible = false; }
                field("To Table Caption"; Rec."To Table Caption") { ApplicationArea = All; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; StyleExpr = BufferTableIDStyle; }
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { ApplicationArea = All; StyleExpr = ImportXMLPortIDStyle; }
                field(ExportFilePath; Rec.DataFilePath) { ApplicationArea = All; }
                field(LastImportBy; Rec.LastImportBy) { ApplicationArea = All; }
                field(LastImportToTargetAt; Rec.LastImportToTargetAt) { ApplicationArea = All; }
                field("Qty.Lines In Src. Table"; "Qty.Lines In Src. Table") { ApplicationArea = All; }
                field("Import Duration (Longest)"; "Import Duration (Longest)") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SelectTablesToAdd)
            {
                CaptionML = DEU = 'Tab. hinzufügen';
                Image = Add;
                ApplicationArea = all;
                trigger OnAction()
                var
                    ObjMgt: Codeunit ObjMgt;
                begin
                    ObjMgt.AddSelectedTables();
                end;
            }
            action(ImportBufferTables)
            {
                Image = ImportDatabase;
                CaptionML = DEU = 'Alle Dateien in Puffertabellen einlesen';
                ApplicationArea = all;
                trigger OnAction()
                var
                    DAMTable: Record DAMTable;
                    Progress: Dialog;
                    Start: DateTime;
                begin
                    if DAMTable.FindSet() then begin
                        Start := CurrentDateTime;
                        Progress.Open('Puffertabellen werden eingelesen\ Tabelle: ############1#');
                        repeat
                            Progress.Update(1, DAMTable."To Table Caption");
                            DAMTable.ImportToBufferTable();
                        until DAMTable.Next() = 0;
                        Progress.Close();
                        Message('Vorgang abgeschlossen\Dauer %1', CurrentDateTime - Start);
                    end;
                end;
            }
            action(ExportALObjects)
            {
                Image = ExportFile;
                ApplicationArea = all;
                CaptionML = DEU = 'Puffertabellen Objekte runterladen';
                trigger OnAction()
                var
                    DAMTable: Record DAMTable;
                begin
                    if DAMTable.FindSet() then
                        repeat
                            DAMTable.DownloadAllALBufferTableFiles(Rec);
                        until DAMTable.Next() = 0;
                end;
            }
            action(TransferSelectedToTargetTable)
            {
                Image = TransferToLines;
                ApplicationArea = all;
                CaptionML = DEU = 'In Zieltabellen übernehmen (Markierte Zeilen)';
                trigger OnAction()
                var
                    DAMTable: Record DAMTable;
                    DAMTable_SELECTED: Record DAMTable;
                    DAMImport: Codeunit DAMImport;
                begin
                    DAMTable_SELECTED.SetCurrentKey("Sort Order");
                    if not GetSelection(DAMTable_SELECTED) then
                        exit;
                    DAMTable_SELECTED.FindSet();
                    repeat
                        DAMTable := DAMTable_SELECTED;
                        DAMImport.ProcessDAMTable(DAMTable, true);
                    until DAMTable_SELECTED.Next() = 0;
                end;
            }
        }
    }

    procedure GetSelection(var DAMTable_SELECTED: Record DAMTable) HasLines: Boolean
    begin
        Clear(DAMTable_SELECTED);
        CurrPage.SetSelectionFilter(DAMTable_SELECTED);
        HasLines := DAMTable_SELECTED.FindFirst();
    end;

    trigger OnAfterGetRecord()
    var
        AllObj: Record AllObjWithCaption;
    begin
        ImportXMLPortIDStyle := 'Unfavorable';
        BufferTableIDStyle := 'Unfavorable';
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