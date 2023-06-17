page 73005 DMTDataFileCard
{
    Caption = 'File Card', comment = 'de-DE=Datei Karte';
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
                Caption = 'General';
                group(DataFilePathGroup)
                {
                    Caption = 'Data File Path', comment = 'de-DE=Datentdatei Pfad';
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
                field(ImportFileConfig; Rec."File Config Code") { ApplicationArea = All; }
            }
            group(ProcessingOptions)
            {
                Caption = 'Processing Options', Comment = 'de-DE=Verarbeitungsoptionen';
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { ApplicationArea = All; Importance = Promoted; }
                field("Import Only New Records"; Rec."Import Only New Records") { ApplicationArea = All; Importance = Promoted; }
            }
            part(Lines; DMTFieldMapping)
            {
                ApplicationArea = All;
                Caption = 'Field Mapping', Comment = 'de-DE=Feldzuordnung';
                SubPageLink = "Data File ID" = field(ID), "Target Table ID" = field("Target Table ID");
            }
            part(Replacements; DMTReplacementAssigmentsPart)
            {
                SubPageLink = "Data File ID" = field(ID), "Target Table ID" = field("Target Table ID"), LineType = const(Assignment);
                ApplicationArea = All;
            }
        }
        area(FactBoxes)
        {
            part(DMTDataFileFactBox_TableInfo; DMTDataFileFactBox)
            {
                ApplicationArea = All;
                Caption = 'Info', Comment = 'de-DE=Info';
            }
            part(DMTDataFileFactBox_Log; DMTDataFileFactBox)
            {
                ApplicationArea = All;
                Caption = 'Log', Comment = 'de-DE=Protokoll';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AutoMigration)
            {
                Caption = 'Auto Migration', Comment = 'de-DE=Autom. Übernahme';
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
                Caption = 'Import to Buffer Table', Comment = 'de-DE=Import in Puffertabelle';
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
                Caption = 'Delete Records In Target Table', Comment = 'de-DE=Datensätze in Zieltabelle löschen';
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

            action(CountLines)
            {
                Caption = 'Count Lines in Target';
                ApplicationArea = All;
                Image = CalcWorkCenterCalendar;
                trigger OnAction()
                var
                    FPBuilder: Codeunit DMTFPBuilder;
                    RecRef: RecordRef;
                    TargetTableView, TargetTableFilter : Text;
                    NoOfLinesInFilterLbl: Label 'Filter:%1 \ No. of Lines in Filter: %2', comment = 'de-DE=Filter:%1 \ Anzahl Zeilen im Filter: %2';
                begin
                    RecRef.Open(Rec."Target Table ID");
                    if TargetTableView <> '' then
                        RecRef.SetView(TargetTableView);
                    if FPBuilder.RunModal(RecRef, true) then begin
                        TargetTableView := RecRef.GetView();
                        TargetTableFilter := RecRef.GetFilters;
                        Message(NoOfLinesInFilterLbl, TargetTableFilter, RecRef.Count);
                    end;
                end;
            }
            action(CountLinesInSource)
            {
                Caption = 'Count Lines in Buffer';
                ApplicationArea = All;
                Image = CalcWorkCenterCalendar;
                trigger OnAction()
                var
                    FPBuilder: Codeunit DMTFPBuilder;
                    RecRef: RecordRef;
                    NoOfLinesInFilterLbl: Label 'Filter:%1 \ No. of Lines in Filter: %2', comment = 'de-DE=Filter:%1 \ Anzahl Zeilen im Filter: %2';
                    TargetTableFilter, TargetTableView : Text;
                begin
                    Rec.InitBufferRef(RecRef);
                    if TargetTableView <> '' then
                        RecRef.SetView(TargetTableView);
                    if FPBuilder.RunModal(RecRef, true) then begin
                        TargetTableView := RecRef.GetView();
                        TargetTableFilter := RecRef.GetFilters;
                        Message(NoOfLinesInFilterLbl, TargetTableFilter, RecRef.Count);
                    end;
                end;
            }

            action(TransferToTargetTable)
            {
                Caption = 'Import to Target Table', Comment = 'de-DE=In Zieltabelle übertragen';
                ApplicationArea = All;
                Image = TransferOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Migrate: Codeunit DMTMigrate;
                begin
                    Migrate.AllFieldsFrom(Rec);
                end;
            }
            action(UpdateFields)
            {
                Caption = 'Update Fields', Comment = 'de-DE=Felder aktualisieren';
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
                Caption = 'Retry Records With Error', Comment = 'de-DE=Fehler erneut verarbeiten';
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
            action(OpenLog)
            {
                Caption = 'Log', Comment = 'de-DE=Protokoll';
                ApplicationArea = All;
                Image = ErrorLog;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Log: Codeunit DMTLog;
                begin
                    Log.ShowLogEntriesFor(Rec);
                end;
            }
            action(CreateXMLPort)
            {
                ApplicationArea = All;
                Image = XMLSetup;
                Caption = 'Create XMLPort', comment = 'de-DE=XMLPort erstellen';

                trigger OnAction()
                begin
                    PageActions.DownloadALXMLPort(Rec);
                end;
            }
            action(CreateBufferTable)
            {
                ApplicationArea = All;
                Image = Table;
                Caption = 'Create Buffer Table', comment = 'de-DE=Puffertabelle erstellen';

                trigger OnAction()
                begin
                    PageActions.DownloadALBufferTableFile(Rec);
                end;
            }
            action(CheckTransferedRecords)
            {
                ApplicationArea = All;
                Image = Table;
                Caption = 'Check Transfered Records', comment = 'de-DE=Übertragene Datensätze Prüfen';

                trigger OnAction()
                var
                    Migrate: Codeunit DMTMigrate;
                    CollationProblems: Dictionary of [RecordId, RecordId];
                    RecordMapping: Dictionary of [RecordId, RecordId];
                    NotTransferedRecords: List of [RecordId];
                begin
                    // RecordMapping := DMTImport.CreateSourceToTargetRecIDMapping(Rec, NotTransferedRecords);
                    CollationProblems := Migrate.FindCollationProblems(RecordMapping);
                    Message('No. of Records not Transfered: %1\' +
                            'No. of Collation Problems: %2', NotTransferedRecords.Count, CollationProblems.Count);
                end;
            }
            action(CreateCode)
            {
                Caption = 'Create AL Mapping Code', comment = 'de-DE=Mapping AL Code erstellen';
                ApplicationArea = All;
                Image = CodesList;
                trigger OnAction()
                var
                    DMTCode: Page DMTCode;
                begin
                    DMTCode.InitForFieldMapping(Rec);
                    DMTCode.Run();
                end;
            }
            action(ExportTargetTableToCSV)
            {
                Caption = 'Export target table to CSV', Comment = 'de-DE=Zieltabelle als CSV exportieren';
                ApplicationArea = All;
                Image = CodesList;
                trigger OnAction()
                begin
                    PageActions.ExportTargetTableToCSV(Rec);
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
        CurrPage.Replacements.Page.InitializeAsAssignmentPerDataFile();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.DMTDataFileFactBox_TableInfo.Page.ShowAsTableInfoAndUpdateOnAfterGetCurrRecord(Rec);
        CurrPage.DMTDataFileFactBox_Log.Page.ShowAsLogAndUpdateOnAfterGetCurrRecord(Rec);
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