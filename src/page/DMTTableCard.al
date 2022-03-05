page 91002 "DMTTableCard"
{
    CaptionML = DEU = 'DMT Tabellenkarte', ENU = 'DMT Table Card';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTTable;
    //DelayedInsert = true;
    DataCaptionExpression = GetCaption();

    layout
    {
        area(Content)
        {
            group(General)
            {
                CaptionML = ENU = 'General', DEU = 'Allgemein';
                field("To Table Caption"; Rec."To Table Caption")
                {
                    ToolTip = 'Data Migration Target Table Caption';
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field(ImportToBufferOption; Rec.BufferTableType)
                {
                    ToolTip = 'Specifies the value of the ImportToBufferOption field.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field("From Table Caption"; Rec."Old Version Table Caption")
                {
                    ToolTip = 'Data Migration Source Table Caption';
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Enabled = FromTableCaption_ENABLED;
                    //Visible = FromTableCaption_VISIBLE;
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
            group(ObjectInfo)
            {
                Caption = 'Objects';
                Visible = ImportXMLPortID_ENABLED;

                field("Import XMLPort ID"; Rec."Import XMLPort ID")
                {
                    ToolTip = 'Specifies the value of the Import XMLPort ID field';
                    ApplicationArea = All;
                    StyleExpr = ImportXMLPortIDStyle;
                    Enabled = ImportXMLPortID_ENABLED;
                    //Visible = ImportXMLPortID_VISIBLE;
                }
                field("Buffer Table ID"; Rec."Buffer Table ID")
                {
                    ToolTip = 'Specifies the value of the Buffer Table ID field.';
                    ApplicationArea = All;
                    StyleExpr = BufferTableIDStyle;
                    Enabled = BufferTableID_ENABLED;
                    //Visible = BufferTableID_VISIBLE;
                    trigger OnAssistEdit()
                    begin
                        Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, Rec."Buffer Table ID"));
                    end;
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
                CaptionML = DEU = 'Daten in Zieltabelle übertragen';
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

    trigger OnAfterGetRecord()
    begin
        EnableControls();
    end;

    local procedure EnableControls()
    begin
        ImportXMLPortID_ENABLED := (Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV");
        BufferTableID_ENABLED := (Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV");
        FromTableCaption_ENABLED := (Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV");
    end;

    local procedure GetCaption(): Text
    begin
        case Rec.BufferTableType of
            Rec.BufferTableType::"Seperate Buffer Table per CSV":
                exit(Rec."To Table Caption");
            Rec.BufferTableType::"Generic Buffer Table for all Files":
                exit(Rec."Filename (Imp.into Gen.Buffer)");
        end
    end;

    procedure EncodeBarcode128b(pText: Text[250]) RetVal: Text[250];
    var
        Checksum: Integer;
        i: Integer;
        StartChar: Char;
        StopChar: Char;
        ChecksumChar: Char;
        CharNo: Integer;
    begin
        //
        // Data Characters  a   b   c   d   e   f
        // Multiply each of the characters (the Code 128 value) with increasing weight.
        // Code 128 Value   65  66  67  68  69  70
        // Weight           *1  *2  *3  *4  *5  *6
        // Sum :            (65*1) + (66*2) + (67*3) + (68*4) + (69*5) + (70*6) = 1435
        // For Code 128B, add an additional 104 to the sum above
        // Total    1435 + 104 = 1539
        // Modulo 103 Check Character:  1539 % 103 = 97
        StartChar := 'š';
        StopChar := 'œ';
        Checksum := 104;  // Code 128A -> 103, Code 128B -> 104, Code 128C -> 105, add an additional 10x to the sum above 
        for i := 1 to STRLEN(pText) do begin
            CharNo := pText[i];
            Checksum := Checksum + (i * (CharNo - 32));
        end;
        ChecksumChar := Checksum MOD 103;
        ChecksumChar := ChecksumChar + 32;
        // convert SPACE to ALT+0128
        pText := CONVERTSTR(pText, ' ', '°');
        RetVal := STRSUBSTNO('%1%2%3%4', StartChar, pText, ChecksumChar, StopChar);
        exit(RetVal);
    end;


    var
        [InDataSet]
        ImportXMLPortIDStyle: Text;
        [InDataSet]
        BufferTableIDStyle: Text;
        [InDataSet]
        ImportXMLPortID_ENABLED: Boolean;
        [InDataSet]
        BufferTableID_ENABLED: Boolean;
        [InDataSet]
        FromTableCaption_ENABLED: Boolean;
}