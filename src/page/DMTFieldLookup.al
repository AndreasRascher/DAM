page 110000 "DMTFieldLookup"
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
    begin
        if IsLoaded then exit;
        Field.SetRange(TableNo, Rec.GetRangeMin(TableNo));
        Field.SetFilter("No.", '<2000000000'); // no system fields
        Field.FindSet(false, false);
        repeat
            TempFieldBuffer.ReadFrom(Field);
            TempFieldBuffer.Insert(false);
        until Field.Next() = 0;
        IsLoaded := true;
        Rec.Copy(TempFieldBuffer, true);
    end;

    var
        [InDataSet]
        IsLoaded: Boolean;
}