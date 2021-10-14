page 91002 "DAMTableCard"
{
    CaptionML = DEU = 'DAM Tabellenkarte', ENU = 'DAM Table Card';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DAMTable;
    DelayedInsert = true;
    DataCaptionFields = "To Table Caption";

    layout
    {
        area(Content)
        {
            group(General)
            {
                CaptionML = ENU = 'General', DEU = 'Allgemein';
                field("From Table Caption"; "Old Version Table Caption")
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
            }
            group(Import)
            {
                CaptionML = DEU = 'Import', ENU = 'Import';
                field("Src.Table ID"; Rec."Old Version Table ID")
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
                ApplicationArea = all;
                CaptionML = ENU = 'Fields Setup', DEU = 'Feldeinrichtung';
                //Editable = LinesEditable;
                SubPageLink = "From Table ID" = field("Buffer Table ID"), "To Table No." = field("To Table ID");
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
                    DAMImport.ProcessFullBuffer();
                    Rec.Get(Rec.RecordId);
                    Rec.LastImportBy := UserId;
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
                    DAMErrorLog: Record DAMErrorLog;
                begin
                    DAMErrorLog.OpenListWithFilter(rec."Buffer Table ID");
                end;
            }
            action(CreateXMLPort)
            {
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                begin
                    rec.DownloadALXMLPort();
                end;
            }
            action(CreateBufferTable)
            {
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                begin
                    Rec.DownloadALBufferTableFile();
                end;
            }

        }
    }
    trigger OnAfterGetCurrRecord()
    var
        AllObj: Record AllObjWithCaption;
    begin
        LinesEditable := not (0 in [Rec."Buffer Table ID", Rec."To Table ID"]);
        ImportXMLPortIDStyle := 'Unfavorable';
        BufferTableIDStyle := 'Unfavorable';
        if AllObj.Get(AllObj."Object Type"::XMLport, Rec."Import XMLPort ID") then
            ImportXMLPortIDStyle := 'Favorable';
        if AllObj.Get(AllObj."Object Type"::Table, Rec."Buffer Table ID") then
            BufferTableIDStyle := 'Favorable';
    end;

    trigger OnModifyRecord(): Boolean
    begin
        LinesEditable := not (0 in [Rec."Old Version Table ID", Rec."To Table ID"]);
    end;

    var
        [InDataSet]
        LinesEditable: Boolean;
        [InDataSet]
        ImportXMLPortIDStyle: Text;
        [InDataSet]
        BufferTableIDStyle: Text;
}