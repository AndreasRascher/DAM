page 50012 "DMTTableCard"
{
    Caption = 'DMT Table Card (Data Migration Tool)', Comment = 'DMT Tabellenkarte (Data Migration Tool)';
    PageType = Document;
    UsageCategory = None;
    SourceTable = DMTTable;
    DataCaptionExpression = GetCaption();

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', comment = 'Allgemein';
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
                    Caption = 'Data File Path', Comment = 'Datendatei Pfad';
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
                field("No.of Records in Buffer Table"; Rec."No.of Records in Buffer Table")
                {
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnAssistEdit()
                    begin
                        Rec.ShowBufferTable();
                    end;
                }
                field("Qty.Lines In Trgt. Table"; Rec.GetNoOfRecordsInTrgtTable())
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Qty.Lines In Trgt. Table', Comment = 'Anz. Datensätze in Zieltabelle';
                    trigger OnAssistEdit()
                    begin
                        Rec.ShowTableContent(Rec."To Table ID");
                    end;
                }
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { ApplicationArea = All; }
                field("Import Only New Records"; "Import Only New Records") { ApplicationArea = All; }
            }
            group(NAVDataSourceProperties)
            {
                Caption = 'Data Source NAV', comment = 'Datenquelle NAV';
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
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { ApplicationArea = All; StyleExpr = ImportXMLPortIDStyle; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; StyleExpr = BufferTableIDStyle; }

            }
            part(Lines; DMTTableCardPart)
            {
                Visible = LinesVisible;
                ApplicationArea = all;
                Caption = 'Fields Setup', Comment = 'Feldeinrichtung';
                SubPageLink = "To Table No." = field("To Table ID"), BufferTableTypeFilter = field(BufferTableType);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportBufferDataFromFile)
            {
                Caption = 'Import to Buffer Table', Comment = 'Import in Puffertabelle';
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
                    EnableControls(); // ShowMappingLines
                end;
            }
            action(DeleteRecordsInTargetTable)
            {
                Caption = 'Delete Records In Target Table', Comment = 'Datensätze in Zieltabelle löschen';
                ApplicationArea = All;
                Image = "Invoicing-Delete";
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    RecRef: RecordRef;
                    DeleteAllRecordsInTargetTableWarningMsg: Label 'Warning! All Records in table "%1" (company "%2") will be deleted. Continue?',
                    Comment = 'Warnung! Alle Datensätze in Tabelle "%1" (Mandant "%2") werden gelöscht. Fortfahren?';
                begin
                    Rec.TestField("To Table ID");
                    CurrPage.SaveRecord();
                    Commit();
                    RecRef.Open(Rec."To Table ID");
                    if confirm(StrSubstNo(DeleteAllRecordsInTargetTableWarningMsg, RecRef.Caption, RecRef.CurrentCompany), false) then begin
                        RecRef.DeleteAll();
                    end;
                end;
            }
            action(TransferToTargetTable)
            {
                Caption = 'Import to Target Table', Comment = 'In Zieltabelle übertragen';
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
                    DMTImport.StartImport(Rec, false, false);
                end;
            }
            action(UpdateFields)
            {
                Caption = 'Update Fields', Comment = 'Felder aktualisieren';
                ApplicationArea = All;
                Image = TransferOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Import: Codeunit DMTImport;
                    UpdateTask: Page DMTUpdateTask;
                begin
                    // Show only Non-Key Fields for selection
                    UpdateTask.LookupMode(true);
                    UpdateTask.Editable := true;
                    if not UpdateTask.InitFieldSelection(Rec) then
                        exit;
                    if UpdateTask.RunModal() = Action::LookupOK then begin
                        Rec.WriteLastFieldUpdateSelection(UpdateTask.GetToFieldNoFilter());
                        Import.StartImport(Rec, false, true);

                    end;
                end;
            }
            action(RetryBufferRecordsWithError)
            {
                Caption = 'Retry Records With Error', Comment = 'Fehler erneut verarbeiten';
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
                    DMTImport.RetryProcessFullBuffer(RecIdList, Rec, false);
                    Rec.Get(Rec.RecordId);
                    Rec.LastImportBy := CopyStr(UserId, 1, MaxStrLen(Rec.LastImportBy));
                    Rec.LastImportToTargetAt := CurrentDateTime;
                    Rec.Modify();
                end;
            }
            action(OpenErrorLog)
            {
                Caption = 'Error Log', Comment = 'Fehlerprotokoll';
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
                    DMTErrorLog.OpenListWithFilter(Rec, false);
                end;
            }
            action(CreateXMLPort)
            {
                ApplicationArea = All;
                Image = XMLSetup;
                Caption = 'Create XMLPort', comment = 'XMLPort erstellen';

                trigger OnAction()
                begin
                    rec.DownloadALXMLPort();
                end;
            }
            action(CreateBufferTable)
            {
                ApplicationArea = All;
                Image = Table;
                Caption = 'Create Buffer Table', comment = 'Puffertabelle erstellen';

                trigger OnAction()
                begin
                    Rec.DownloadALBufferTableFile();
                end;
            }

        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitOrRefreshFieldSortOrder();
    end;

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
        UseXMLPortAndBufferTable := (Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV");
        LinesVisible := true;
        // LinesVisible := (Rec."To Table ID" <> 0) and
        //                 (Rec."No.of Records in Buffer Table" > 0) and
        //                 (Rec."Data Source Type" <> Rec."Data Source Type"::" ");
        NAVDataSourcePropertiesVisible := Rec."Data Source Type" = Rec."Data Source Type"::"NAV CSV Export";
        CurrPage.Lines.Page.SetBufferTableType(Rec.BufferTableType);
    end;

    local procedure GetCaption(): Text
    begin
        case Rec.BufferTableType of
            Rec.BufferTableType::"Seperate Buffer Table per CSV":
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