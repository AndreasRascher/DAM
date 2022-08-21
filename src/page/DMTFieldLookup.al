page 50022 "DMTFieldLookup"
{
    Caption = 'Fields', comment = 'Felder';
    PageType = List;
    UsageCategory = None;
    SourceTable = DMTFieldBuffer;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(fields)
            {
                field("Field Caption"; Rec."Field Caption") { ApplicationArea = All; }
                field(FieldName; Rec.FieldName) { ApplicationArea = All; }
                field(TableNo; Rec.TableNo) { ApplicationArea = All; }
                field("Type Name"; Rec."Type Name") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        LoadLines();
    end;

    procedure LoadLines()
    var
        Field: Record Field;
        TempFieldBuffer: Record DMTFieldBuffer temporary;
        DMTTable: Record DMTTable;
        GenBuffTable: Record DMTGenBuffTable;
        BuffTableCaptions: Dictionary of [Integer, Text];
        FieldNo: Integer;
    begin
        if IsLoaded then exit;
        DMTTable.Get(Rec.GetRangeMin("To Table No. Filter"));
        case DMTTable.BufferTableType of
            DMTTable.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    GenBuffTable.GetColCaptionForImportedFile(DMTTable.GetDataFilePath(), BuffTableCaptions);
                    foreach FieldNo in BuffTableCaptions.Keys do begin
                        TempFieldBuffer.TableNo := GenBuffTable.RecordId.TableNo;
                        TempFieldBuffer."No." := FieldNo + 1000;
                        TempFieldBuffer."Field Caption" := CopyStr(BuffTableCaptions.Get(FieldNo), 1, MaxStrLen(TempFieldBuffer."Field Caption"));
                        TempFieldBuffer.Insert();
                    end;
                    IsLoaded := true;
                end;

            DMTTable.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    Field.SetRange(TableNo, DMTTable."Buffer Table ID");
                    Field.SetFilter("No.", '<2000000000'); // no system fields
                    Field.FindSet(false, false);
                    repeat
                        TempFieldBuffer.ReadFrom(Field);
                        TempFieldBuffer.Insert(false);
                    until Field.Next() = 0;
                    IsLoaded := true;
                end;
        end;

        Rec.Copy(TempFieldBuffer, true);
    end;

    var
        [InDataSet]
        IsLoaded: Boolean;
}