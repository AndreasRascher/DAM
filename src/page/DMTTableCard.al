page 91002 "DMTTableCard"
{
    CaptionML = DEU = 'DMT Tabellenkarte', ENU = 'DMT Table Card';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTTable;
    DelayedInsert = true;
    DataCaptionFields = "To Table Caption";

    layout
    {
        area(Content)
        {
            group(General)
            {
                CaptionML = ENU = 'General', DEU = 'Allgemein';
                field("From Table Caption"; Rec."Old Version Table Caption")
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("To Table Caption"; Rec."To Table Caption")
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Import XMLPort ID"; Rec."Import XMLPort ID")
                {
                    ToolTip = 'Specifies the value of the Import XMLPort ID field';
                    ApplicationArea = All;
                    StyleExpr = ImportXMLPortIDStyle;
                }
                field("Buffer Table ID"; Rec."Buffer Table ID")
                {
                    ToolTip = 'Specifies the value of the Buffer Table ID field.';
                    ApplicationArea = All;
                    StyleExpr = BufferTableIDStyle;
                    trigger OnAssistEdit()
                    begin
                        Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, Rec."Buffer Table ID"));
                    end;
                }
                grid(dummy)
                {
                    GridLayout = Rows;
                    group(dummy2)
                    {
                        CaptionML = DEU = 'Datendatei Pfad', ENU = 'Data File Path';
                        field(ExportFilePath; Rec.DataFilePath)
                        {
                            ShowCaption = false;
                            ApplicationArea = All;
                            Importance = Promoted;
                        }
                    }
                }
            }
            group(TableMigration)
            {
                CaptionML = DEU = 'Tabellen', ENU = 'Tables';
                field("Src.Table ID"; Rec."Old Version Table ID") { ApplicationArea = All; ShowMandatory = true; }
                field("Qty.Lines In Src. Table"; Rec."Qty.Lines In Src. Table") { ApplicationArea = All; Importance = Promoted; }
                field("Trgt.Table ID"; Rec."To Table ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Qty.Lines In Trgt. Table"; Rec."Qty.Lines In Trgt. Table") { ApplicationArea = All; }
                field("No.of Fields in Trgt. Table"; "No.of Fields in Trgt. Table") { ApplicationArea = All; }

            }
            group(DataMigration)
            {
                CaptionML = DEU = 'Datenmigration', ENU = 'Data Migration';
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { ApplicationArea = All; }
            }
            part(FieldsPart; DMTTableCardPart)
            {
                ApplicationArea = all;
                CaptionML = ENU = 'Fields Setup', DEU = 'Feldeinrichtung';
                SubPageLink = "To Table No." = field("To Table ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportBufferDataFromFile)
            {
                CaptionML = DEU = 'Datendatei in Puffertabelle importieren';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.ImportToBufferTable();
                end;
            }
            action(TransferToTargetTable)
            {
                CaptionML = DEU = 'Daten in Zieltabelle ??bertragen';
                ApplicationArea = All;
                Image = TransferOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DMTImport: Codeunit DMTImport;
                begin
                    DMTImport.ProcessDMTTable(Rec, false);
                end;
            }
            action(RetryBufferRecordsWithError)
            {
                CaptionML = DEU = 'Fehler erneut verarbeiten';
                ApplicationArea = All;
                Image = TransferOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DMTImport: Codeunit DMTImport;
                    DMTErrorLogQry: Query DMTErrorLogQry;
                    RecIdList: list of [RecordID];
                begin
                    DMTErrorLogQry.setrange(Import_from_Table_No_, REc."Buffer Table ID");
                    DMTErrorLogQry.Open();
                    while DMTErrorLogQry.Read() do begin
                        RecIdList.Add(DMTErrorLogQry.FromID);
                    end;
                    DMTImport.SetDMTTableToProcess(Rec);
                    DMTImport.ProcessFullBuffer(RecIdList);
                    Rec.Get(Rec.RecordId);
                    Rec.LastImportBy := CopyStr(UserId, 1, MaxStrLen(Rec.LastImportBy));
                    Rec.LastImportToTargetAt := CurrentDateTime;
                    Rec.Modify();
                end;
            }
            action(OpenErrorLog)
            {
                Caption = 'Fehlerprotokoll ??ffnen';
                ApplicationArea = All;
                Image = ErrorLog;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DMTErrorLog: Record DMTErrorLog;
                begin
                    DMTErrorLog.OpenListWithFilter(rec."Buffer Table ID");
                end;
            }
            action(CreateXMLPort)
            {
                ApplicationArea = All;
                Image = XMLSetup;

                trigger OnAction()
                begin
                    rec.DownloadALXMLPort();
                end;
            }
            action(CreateBufferTable)
            {
                ApplicationArea = All;
                Image = Table;

                trigger OnAction()
                begin
                    Rec.DownloadALBufferTableFile();
                end;
            }

        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        ImportXMLPortIDStyle := 'Unfavorable';
        BufferTableIDStyle := 'Unfavorable';
        if Rec.ImportXMLPortExits() then
            ImportXMLPortIDStyle := 'Favorable';
        if Rec.BufferTableExits() then
            BufferTableIDStyle := 'Favorable';
        Rec.TryFindExportDataFile();
    end;

    var
        [InDataSet]
        ImportXMLPortIDStyle: Text;
        [InDataSet]
        BufferTableIDStyle: Text;
}