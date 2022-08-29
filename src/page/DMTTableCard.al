page 110012 "DMTTableCard"
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
                field("Dest. Table Caption"; Rec."Target Table Caption")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
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
                field("Qty.Lines In Trgt. Table"; Rec."No. of Lines In Trgt. Table")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Qty.Lines In Trgt. Table', Comment = 'Anz. Datensätze in Zieltabelle';
                    trigger OnAssistEdit()
                    begin
                        Rec.ShowTableContent(Rec."Target Table ID");
                    end;
                }
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { ApplicationArea = All; }
                field("Import Only New Records"; Rec."Import Only New Records") { ApplicationArea = All; }
            }

            group(DataFile)
            {
                group(Path)
                {
                    field(DataFilePath; Rec.GetDataFilePath())
                    {
                        Caption = 'Data File Path', Comment = 'Datendatei Pfad';
                        ApplicationArea = All;
                        Importance = Promoted;
                        StyleExpr = DataFilePathStyleExpr;
                        trigger OnAssistEdit()
                        var
                            DMTMgt: Codeunit DMTMgt;
                            SelectedPath: Text;
                        begin
                            SelectedPath := DMTMgt.LookUpPath(Rec.DataFileFolderPath, false);
                            Rec.SetDataFilePath(SelectedPath);
                        end;
                    }
                    field("DataFile Created At"; Rec."DataFile Created At") { ApplicationArea = All; }
                }
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
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { ApplicationArea = All; StyleExpr = Rec.ImportXMLPortIDStyle; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; StyleExpr = Rec.BufferTableIDStyle; }

            }
            part(Lines; DMTTableCardPart)
            {
                ApplicationArea = all;
                Caption = 'Fields Setup', Comment = 'Feldeinrichtung';
                SubPageLink = "Target Table ID" = field("Target Table ID"), BufferTableTypeFilter = field(BufferTableType);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AutoMigration)
            {
                Caption = 'Autom. Übernahme', Comment = 'Auto Migration';
                ApplicationArea = All;
                Image = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    Commit();
                    PageActions.AutoMigration(Rec);
                    EnableControls(); // ShowMappingLines;
                end;
            }
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
                    Rec.TestField("Target Table ID");
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
                Promoted = false;

                trigger OnAction()
                var
                    RecRef: RecordRef;
                    DeleteAllRecordsInTargetTableWarningMsg: Label 'Warning! All Records in table "%1" (company "%2") will be deleted. Continue?',
                    Comment = 'Warnung! Alle Datensätze in Tabelle "%1" (Mandant "%2") werden gelöscht. Fortfahren?';
                begin
                    Rec.TestField("Target Table ID");
                    CurrPage.SaveRecord();
                    Commit();
                    RecRef.Open(Rec."Target Table ID");
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
                    if Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV" then
                        DMTErrorLogQry.setrange(Import_from_Table_No_, Rec."Buffer Table ID");
                    if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then begin
                        DMTErrorLogQry.setrange(Import_from_Table_No_, Database::DMTGenBuffTable);
                        DMTErrorLogQry.SetRange(DMTErrorLogQry.DataFileFolderPath, rec.DataFileFolderPath);
                        DMTErrorLogQry.SetRange(DMTErrorLogQry.DataFileName, rec.DataFileName);
                    end;
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
        Rec.FilterGroup(2);
        Rec.SetRange(CompanyNameFilter, CompanyName);
        Rec.FilterGroup(0);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.UpdateIndicators();
        Rec.TryFindExportDataFile();
        Rec.UpdateNAVSchemaFileStatus();
        DataFilePathStyleExpr := Rec.DataFilePathStyle;
    end;

    trigger OnAfterGetRecord()
    begin
        EnableControls();
    end;

    local procedure EnableControls()
    begin
        UseXMLPortAndBufferTable := (Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV");
        NAVDataSourcePropertiesVisible := Rec."Data Source Type" = Rec."Data Source Type"::"NAV CSV Export";
    end;

    local procedure GetCaption(): Text
    begin
        if rec.DataFileName = '' then
            exit(StrSubstNo('<%1>', Rec."Target Table Caption"))
        else
            exit(StrSubstNo('%1', Rec.DataFileName));
    end;

    var
        [InDataSet]
        DataFilePathStyleExpr: Text;
        [InDataSet]
        UseXMLPortAndBufferTable, NAVDataSourcePropertiesVisible : Boolean;
        PageActions: Codeunit DMTPageActions;

}