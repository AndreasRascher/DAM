page 91002 "DMTTableCard"
{
    CaptionML = DEU = 'DMT Tabellenkarte (Data Migration Tool)', ENU = 'DMT Table Card (Data Migration Tool)';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTTable;

    DataCaptionExpression = GetCaption();

    layout
    {
        area(Content)
        {
            group(General)
            {
                CaptionML = ENU = 'General', DEU = 'Allgemein';
                field("Dest. Table Caption"; Rec."Dest.Table Caption")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field(DataFilePath; Rec.DataFilePath)
                {
                    CaptionML = DEU = 'Datendatei Pfad', ENU = 'Data File Path';
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Data Source Type"; Rec."Data Source Type")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
            }
            group(NAVDataSourceProperties)
            {
                CaptionML = DEU = 'Datenquelle NAV', ENU = 'Data Source NAV';
                Visible = NAVDataSourcePropertiesVisible;
                field(BufferTableType; Rec.BufferTableType)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field("NAV Schema File Status"; Rec."NAV Schema File Status") { ApplicationArea = All; }
                field("NAV Src.Table Caption"; Rec."NAV Src.Table Caption") { ApplicationArea = All; }
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { ApplicationArea = All; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; }

            }
            part(Lines; DMTTableCardPart)
            {
                Visible = LinesVisible;
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
                CaptionML = DEU = 'Import in Puffertabelle';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.TestField("To Table ID");
                    CurrPage.SaveRecord();
                    Commit();
                    Rec.ImportToBufferTable();
                end;
            }
            action(TransferToTargetTable)
            {
                CaptionML = DEU = 'In Zieltabelle übertragen';
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
                    DMTImport.StartImport(Rec, false);
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
                    DMTImport.ProcessFullBuffer(RecIdList, Rec);
                    Rec.Get(Rec.RecordId);
                    Rec.LastImportBy := CopyStr(UserId, 1, MaxStrLen(Rec.LastImportBy));
                    Rec.LastImportToTargetAt := CurrentDateTime;
                    Rec.Modify();
                end;
            }
            action(OpenErrorLog)
            {
                Caption = 'Fehlerprotokoll öffnen';
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
                    DMTErrorLog.OpenListWithFilter(Rec);
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
        if Rec.CustomBufferTableExits() then
            BufferTableIDStyle := 'Favorable';
        Rec.TryFindExportDataFile();
        Rec.UpdateNAVSchemaFileStatus();
    end;

    trigger OnAfterGetRecord()
    begin
        EnableControls();
    end;

    local procedure EnableControls()
    begin
        UseXMLPortAndBufferTable := (Rec.BufferTableType = Rec.BufferTableType::"Custom Buffer Table per file");
        LinesVisible := (Rec."To Table ID" <> 0) and
                        ("Qty.Lines In Src. Table" > 0) and
                        (Rec."Data Source Type" <> Rec."Data Source Type"::" ");
        NAVDataSourcePropertiesVisible := Rec."Data Source Type" = Rec."Data Source Type"::"NAV CSV Export";
        CurrPage.Lines.Page.SetBufferTableType(Rec.BufferTableType);
    end;

    local procedure GetCaption(): Text
    begin
        case Rec.BufferTableType of
            Rec.BufferTableType::"Custom Buffer Table per file":
                exit(Rec."Dest.Table Caption");
            Rec.BufferTableType::"Generic Buffer Table for all Files":
                exit(Rec.DataFilePath);
        end
    end;

    var
        [InDataSet]
        ImportXMLPortIDStyle: Text;
        [InDataSet]
        BufferTableIDStyle: Text;
        [InDataSet]
        UseXMLPortAndBufferTable: Boolean;
        [InDataSet]
        LinesVisible: Boolean;
        [InDataSet]
        NAVDataSourcePropertiesVisible: boolean;
}