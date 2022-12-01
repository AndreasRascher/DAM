page 110026 DMTDataFileCard
{
    Caption = 'File Card', comment = 'Datei Karte';
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
                        StyleExpr = CurrDataFilePathStyle;
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
            group(ProcessingOptions)
            {
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { ApplicationArea = All; }
                field("Import Only New Records"; Rec."Import Only New Records") { ApplicationArea = All; }
            }
            part(Lines; DMTFieldMapping)
            {
                ApplicationArea = all;
                Caption = 'Field Mapping', Comment = 'Feldzuordnung';
                SubPageLink = "Data File ID" = field(ID), "Target Table ID" = field("Target Table ID");
            }
        }
        area(FactBoxes)
        {
            part(DMTDataFileFactBox; DMTDataFileFactBox)
            {
                ApplicationArea = All;
                SubPageLink = ID = field(ID);
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
                    SaveAndCommitCurrRecIfNotEmpty();
                    PageActions.AutoMigration(Rec);
                    Rec.UpdateIndicators();
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
                    PageActions.ImportToBufferTable(Rec, false);
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
                    ChangeRecordWithPerm: Codeunit ChangeRecordWithPerm;
                begin
                    ChangeRecordWithPerm.DeleteRecordsInTargetTable(Rec);
                    PageActions.UpdateQtyLinesInBufferTable(Rec);
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
                    DMTImportNew: Codeunit DMTImport;
                begin
                    DMTImportNew.StartImport(Rec, false, false, '', '');
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
                begin
                    PageActions.UpdateFields(Rec);
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
                    CollationProblems: Dictionary of [RecordId, RecordId];
                    RecordMapping: Dictionary of [RecordId, RecordId];
                    NotTransferedRecords: List of [RecordId];
                begin
                    // RecordMapping := DMTImport.CreateSourceToTargetRecIDMapping(Rec, NotTransferedRecords);
                    CollationProblems := DMTImport.FindCollationProblems(RecordMapping);
                    Message('No. of Records not Transfered: %1\' +
                            'No. of Collation Problems: %2', NotTransferedRecords.Count, CollationProblems.Count);
                end;
            }
            action(CreateCode)
            {
                Caption = 'Create Mapping Code';
                ApplicationArea = all;
                Image = CodesList;
                trigger OnAction()
                var
                    DMTCode: Page DMTCode;
                begin
                    DMTCode.InitForFieldMapping(Rec);
                    DMTCode.Run();
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
        Rec.UpdateIndicators();
        FullDataFilePathText := Rec.FullDataFilePath();
        CurrDataFilePathStyle := Rec.DataFileExistsStyle;
        Rec.UpdateFileRecProperties(false);
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

    procedure SaveAndCommitCurrRecIfNotEmpty()
    begin
        if Rec.ID <> 0 then
            CurrPage.SaveRecord();
        Commit();
    end;


    var
        PageActions: Codeunit DMTDataFilePageAction;
        CurrDataFilePathStyle: Text;
        FullDataFilePathText: Text;
}