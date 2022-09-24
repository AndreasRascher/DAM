page 110026 DMTDataFileCard
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = DMTDataFile;
    DataCaptionExpression = Rec.FullDataFilePath();
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                group(DataFilePathGroup)
                {
                    Caption = 'Data File Path', comment = 'Datentdatei Pfad';
                    field(DataFilePath; FullDataFilePathText)
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ShowCaption = false;
                        ShowMandatory = true;
                        // StyleExpr = DataFilePathStyleExpr;
                        trigger OnAssistEdit()
                        begin
                            SelectDataFilePath();
                        end;
                    }
                }
                field("Target Table ID"; Rec."Target Table ID") { ApplicationArea = All; ShowMandatory = true; }
                field(BufferTableType; Rec.BufferTableType) { ApplicationArea = All; }
                field("NAV Src.Table No."; Rec."NAV Src.Table No.") { ApplicationArea = All; }
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { ApplicationArea = All; StyleExpr = Rec.ImportXMLPortIDStyle; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; StyleExpr = Rec.BufferTableIDStyle; }
            }
            group(DataFile)
            {
                Caption = 'DataFile', Comment = 'Datei';
                group(DisplayAmongEachOtherGroup)
                {
                    ShowCaption = false;
                    group(details)
                    {
                        ShowCaption = false;
                        grid(Line2)
                        {
                            group(Grid2Line1)
                            {
                                Caption = 'Created At';
                                field("DataFile Created At"; Rec."Created At") { ApplicationArea = All; ShowCaption = false; Importance = Additional; }
                            }
                            group(Grid2Line2)
                            {
                                Caption = 'Size';
                                field("DataFile Size"; Rec."Size") { ApplicationArea = All; ShowCaption = false; Importance = Additional; }
                            }
                            group(Grid2Line3)
                            {
                                Caption = 'Last Import To Buffer At';
                                field(LastImportToBufferAt; Rec.LastImportToBufferAt) { ApplicationArea = All; ShowCaption = false; Importance = Additional; }
                            }
                        }
                    }
                }
            }
            group(ProcessingOptions)
            {
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { ApplicationArea = All; }
                field("Allow Usage of Try Function"; Rec."Allow Usage of Try Function") { ApplicationArea = All; }
                field("Import Only New Records"; Rec."Import Only New Records") { ApplicationArea = All; }
            }
            part(Lines; DMTFieldMapping)
            {
                ApplicationArea = all;
                Caption = 'Field Mapping', Comment = 'Feldzuordnung';
                SubPageLink = "Data File ID" = Field(ID), "Target Table ID" = field("Target Table ID");
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
                    // PageActions.AutoMigration(Rec);
                    // EnableControls(); // ShowMappingLines;
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
                    PageActions.ImportToBufferTable(Rec);
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
                        if not RecRef.IsEmpty then
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
                    DMTImportNew: Codeunit DMTImportNEW;
                begin
                    DMTImportNew.StartImport(Rec, false, false);
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
                    Import: Codeunit DMTImportNEW;
                    UpdateTaskNew: Page DMTUpdateTaskNew;
                begin
                    // Show only Non-Key Fields for selection
                    UpdateTaskNew.LookupMode(true);
                    UpdateTaskNew.Editable := true;
                    if not UpdateTaskNew.InitFieldSelection(Rec) then
                        exit;
                    if UpdateTaskNew.RunModal() = Action::LookupOK then begin
                        Rec.WriteLastFieldUpdateSelection(UpdateTaskNew.GetToFieldNoFilter());
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
                begin
                    PageActions.RetryBufferRecordsWithError(Rec);
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
                    PageActions.DownloadALXMLPort(Rec);
                end;
            }
            action(CreateBufferTable)
            {
                ApplicationArea = All;
                Image = Table;
                Caption = 'Create Buffer Table', comment = 'Puffertabelle erstellen';

                trigger OnAction()
                begin
                    PageActions.DownloadALBufferTableFile(Rec);
                end;
            }
            action(CheckTransferedRecords)
            {
                ApplicationArea = All;
                Image = Table;
                Caption = 'Check Transfered Records', comment = 'Übertragene Datensätze Prüfen';

                trigger OnAction()
                var
                    DMTImport: Codeunit DMTImport;
                    NotTransferedRecords: List of [RecordId];
                    RecordMapping: Dictionary of [RecordId, RecordId];
                    CollationProblems: Dictionary of [RecordId, RecordId];
                begin
                    // RecordMapping := DMTImport.CreateSourceToTargetRecIDMapping(Rec, NotTransferedRecords);
                    CollationProblems := DMTImport.FindCollationProblems(RecordMapping);
                    Message('No. of Records not Transfered: %1\' +
                            'No. of Collation Problems: %2', NotTransferedRecords.Count, CollationProblems.Count);
                end;
            }

        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitFlowFilters();
    end;

    trigger OnAfterGetRecord()
    begin
        FullDataFilePathText := Rec.FullDataFilePath();
    end;

    local procedure SelectDataFilePath()
    var
        FileRec: Record File;
        DMTMgt: Codeunit DMTMgt;
    begin
        if DMTMgt.LookUpPath(FileRec, Rec.Path, false) then begin
            Rec.Path := FileRec.Path;
            Rec.Name := FileRec.Name;
            Rec.Size := FileRec.Size;
            Rec."Created At" := CreateDateTime(FileRec.Date, FileRec.Time);
            Rec.Insert(true);
            CurrPage.Update();
        end;
    end;

    var
        PageActions: Codeunit DMTDataFilePageAction;
        FullDataFilePathText: Text;
}