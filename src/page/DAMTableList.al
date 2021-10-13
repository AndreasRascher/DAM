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
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SelectTablesToAdd)
            {
                trigger OnAction()
                var
                    ObjMgt: Codeunit ObjMgt;
                begin
                    ObjMgt.AddSelectedTables();
                end;
            }
            action(ImportBufferTables)
            {
                trigger OnAction()
                var
                    DAMTable: Record DAMTable;
                begin
                    if DAMTable.FindSet() then
                        repeat
                            DAMTable.ImportToBufferTable();
                        until DAMTable.Next() = 0;
                end;
            }
            action(ExportBufferTables)
            {
                CaptionML = DEU = 'Puffertabellen Objekte runterladen';
                trigger OnAction()
                var
                    DAMTable: Record DAMTable;
                begin
                    if DAMTable.FindSet() then
                        repeat
                            DAMTable.DownloadAllALBufferTableFiles(Rec, TextEncoding::MSDos);
                        until DAMTable.Next() = 0;
                end;
            }
        }
    }

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