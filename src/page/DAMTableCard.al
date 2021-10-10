page 90001 "DAMTableCard"
{
    CaptionML = DEU = 'DAM Tabellenkarte', ENU = 'DAM Table Card';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DAMTable;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                CaptionML = ENU = 'General', DEU = 'Allgemein';
                field("From Table Caption"; "From Table Caption")
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("To Table Caption"; "To Table Caption")
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                }
                field("Import XMLPort ID"; Rec."Import XMLPort ID")
                {
                    ToolTip = 'Specifies the value of the Import XMLPort ID field';
                    ApplicationArea = All;
                }
            }
            group(Import)
            {
                CaptionML = DEU = 'Import', ENU = 'Import';
                field("Src.Table ID"; Rec."From Table ID")
                {
                    ToolTip = 'Specifies the value of the Src.Table ID field';
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Qty.Lines In Src. Table"; Rec."Qty.Lines In Src. Table")
                {
                    ToolTip = 'Specifies the value of the Qty.Lines In Src. Table field';
                    ApplicationArea = All;
                }
                field("Buffer Table ID"; Rec."Buffer Table ID")
                {
                    ToolTip = 'Specifies the value of the Buffer Table ID field.';
                    ApplicationArea = All;
                }

                grid(dummy)
                {
                    GridLayout = Rows;
                    group(dummy2)
                    {
                        CaptionML = DEU = 'Exportdatei Path', ENU = 'Export File Path';
                        field(ExportFilePath; Rec.ExportFilePath)
                        {
                            ShowCaption = false;
                            ApplicationArea = All;
                            Importance = Promoted;
                        }
                    }
                }
            }
            group(DataMigration)
            {

                CaptionML = DEU = 'Datenmigration', ENU = 'Data Migration';
                field("Trgt.Table ID"; Rec."To Table ID")
                {
                    ToolTip = 'Specifies the value of the Trgt.Table ID field';
                    ApplicationArea = All;
                    ShowMandatory = true;
                }

                field("Qty.Lines In Trgt. Table"; Rec."Qty.Lines In Trgt. Table")
                {
                    ToolTip = 'Specifies the value of the Qty.Lines In Trgt. Table field';
                    ApplicationArea = All;
                }

                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger")
                {
                    ToolTip = 'Specifies the value of the Use OnInsert Trigger field';
                    ApplicationArea = All;
                }

            }
            part(FieldsPart; DAMTableCardPart)
            {
                CaptionML = ENU = 'Fields Setup', DEU = 'Feldeinrichtung';
                Editable = LinesEditable;
                SubPageLink = "From Table ID" = field("From Table ID"), "To Table ID" = field("To Table ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportBufferDataFromFile)
            {
                CaptionML = DEU = 'Daten aus Puffertabelle importieren';
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
                CaptionML = DEU = 'Daten in Zieltabelle übertragen';
                ApplicationArea = All;
                Image = TransferOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DAMImport: Codeunit DAMImport;
                begin
                    DAMImport.SetObjectIDs(Rec);
                    DAMImport.ProcessFullBuffer('');
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
                    DAMErrorLog: Record DAMErrorLog;
                begin
                    DAMErrorLog.OpenListWithFilter(rec."From Table ID");
                end;
            }
            action(XMLExport)
            {
                ApplicationArea = All;
                Image = CreateXMLFile;

                trigger OnAction()
                var
                    XMLBackup: Codeunit XMLBackup;
                begin
                    XMLBackup.Export();
                end;
            }
            action(XMLImport)
            {
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                var
                    XMLBackup: Codeunit XMLBackup;
                begin
                    XMLBackup.Import();
                end;
            }
            action(CreateXMLPort)
            {
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                var
                    DAMObjectGenerator: Codeunit DAMObjectGenerator;
                begin
                    DAMObjectGenerator.DownloadAsMDDosFile(
                        DAMObjectGenerator.CreateALXMLPort(Rec),
                        StrSubstNo('XMLPORT %1 - T%2Import.al', Rec."Import XMLPort ID", "From Table ID"));
                end;
            }
            action(CreateBufferTable)
            {
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                var
                    DAMObjectGenerator: Codeunit DAMObjectGenerator;
                begin
                    DAMObjectGenerator.DownloadAsMDDosFile(
                        DAMObjectGenerator.CreateALTable(Rec),
                        StrSubstNo('TABLE %1 - T%2Buffer.al', Rec."Buffer Table ID", "From Table ID"));
                end;
            }

        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        LinesEditable := not (0 in [Rec."From Table ID", Rec."To Table ID"]);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        LinesEditable := not (0 in [Rec."From Table ID", Rec."To Table ID"]);
    end;

    var
        [InDataSet]
        LinesEditable: Boolean;
}