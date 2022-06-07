page 81138 "Data Source Card"
{
    CaptionML = DEU = 'Datenquelle Karte', ENU = 'Data Source Card';
    PageType = Document;
    SourceTable = DMTDataSourceHeader;
    LinksAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                CaptionML = ENU = 'General', DEU = 'Allgemein';
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Data Source Type"; Rec."Data Source Type")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field(FilePath; Rec.FilePath) { ApplicationArea = All; }
                field(FileName; Rec.FileName) { ApplicationArea = All; }
            }
            group(CSV)
            {
                CaptionML = ENU = 'CSV', DEU = 'CSV';
                Visible = CSVGroupVisible;
                field("CSV Field Delimiter"; Rec."CSV Field Delimiter") { ApplicationArea = All; }
                field("CSV Field Seperator"; Rec."CSV Field Seperator") { ApplicationArea = All; }
                field("CSV Record Seperator"; Rec."CSV Record Seperator") { ApplicationArea = All; }
            }
            group(NAV_BC)
            {
                CaptionML = ENU = 'NAV/BC', DEU = 'NAV/BC';
                Visible = NAVGroupVisible;
                field("NAV Schema File Status"; Rec."NAV Schema File Status")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        Message('ToDo: Import anbieten, Schema anzeigen');
                    end;
                }
                field("NAV Src.Table No."; Rec."NAV Src.Table No.") { ApplicationArea = All; Enabled = IsSchemaFileImported; }
                field("NAV Src.Table Name"; Rec."NAV Src.Table Name") { ApplicationArea = All; Enabled = IsSchemaFileImported; }
                field("NAV Src.Table Caption"; Rec."NAV Src.Table Caption") { ApplicationArea = All; Enabled = IsSchemaFileImported; }
            }
            part(Lines; DataSourceCardPart)
            {
                ApplicationArea = All;
                CaptionML = DEU = 'Spalten', ENU = 'Columns';
                SubPageLink = "Data Source Code" = field(Code);
            }
        }
    }
    procedure EnableControls()
    var
        FieldBuffer: Record DMTFieldBuffer;
    begin
        NAVGroupVisible := Rec."Data Source Type" = Rec."Data Source Type"::"NAV CSV Export";
        CSVGroupVisible := Rec."Data Source Type" = Rec."Data Source Type"::"Custom CSV";
        LinesVisible := Rec."Data Source Type" <> Rec."Data Source Type"::" ";
        IsSchemaFileImported := not FieldBuffer.IsEmpty;
    end;

    trigger OnOpenPage()
    begin
        EnableControls();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        EnableControls();
    end;

    trigger OnAfterGetRecord()
    begin
        EnableControls();
    end;

    var
        [InDataSet]
        NAVGroupVisible: Boolean;
        [InDataSet]
        CSVGroupVisible: Boolean;
        [InDataSet]
        LinesVisible: Boolean;
        [InDataSet]
        IsSchemaFileImported: Boolean;
}
